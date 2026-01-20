local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'
local Consts = require 'constants'
local rect = require 'engine.math.rectangle'
local EntityDrawType = require 'engine.enums.entity_draw_type'
local TablePool = require 'engine.utils.table_pool'

---@class Entities : SignalObject
---@field player Player
---@field entities Entity[]
---@field entitiesHash table<string, Entity>
---@field entitiesYSort Entity[]
---@field entitiesBackgroundDraw Entity[]
---@field mapWidth integer
---@field mapHeight integer
---@field tileEntities table<integer, Tile[]>
local Entities = Class { __includes = SignalObject,
  init = function(self, gameScreen, player)
    SignalObject.init(self)
    self:signal('entity_added')
    self:signal('entity_removed')
    self:signal('tile_entity_added')
    self:signal('tile_entity_removed')
    self.player = player
    self.entities = { }
    self.entitiesHash = { }
    self.entitiesBackgroundDraw = { }
    self.entitiesYSort = { }

    self.mapWidth = nil
    self.mapHeight = nil
    self.tileEntities = { }
  end
}

--- y sort function to sort entities with
---@param entityA Entity
---@param entityB Entity
---@return boolean
local function ySort(entityA, entityB)
  local _, ay = entityA:getPosition()
  local _, by = entityB:getPosition()
  return by > ay
end


local function drawEntity(ent)
  if ent.isVisible == nil then
    ent:draw()
  elseif ent:isVisible() then
    ent:draw()
  end
end

--- sets player
---@param player Player
---@param awakeEntity boolean?
function Entities:setPlayer(player, awakeEntity)
  if awakeEntity == nil then awakeEntity = true end
  assert(not self.entitiesHash[player:getName()])
  self.player = player
  lume.push(self.entities, player)
  self.entitiesHash[self.player:getName()] = player
  lume.push(self.entitiesYSort, player)
  if awakeEntity then
    player:awake()
  end

  -- connect to player signals
  player:connect('spawned_entity', self, 'onSpawnedEntity')
end

--- gets player
---@return Player player
function Entities:getPlayer()
  return self.player
end

---adds entity
---@param entity Entity
---@param awakeEntity boolean? default true
function Entities:addEntity(entity, awakeEntity)
  if entity:getName() == "" then
    error(entity:getType())
  end
  
  assert(entity:getName() and entity:getName() ~= "", 'Entity requires name')
  assert(not entity:isTile(), 'Tile Entity should be added via Entities:addTileEntity')
  if awakeEntity == nil then awakeEntity = true end
  lume.push(self.entities, entity)
  self.entitiesHash[entity:getName()] = entity

  -- determine entity draw type
  local drawType = entity:getDrawType()
  if drawType == EntityDrawType.ySort then
    lume.push(self.entitiesYSort, entity)
  elseif drawType == EntityDrawType.background then
    lume.push(self.entitiesBackgroundDraw, entity)
  end

  --connect to entity signals
  entity:connect('entity_destroyed', self, 'onEntityDestroyed')
  entity:connect('spawned_entity', self, 'onSpawnedEntity')
  entity:added()
  if awakeEntity then
    entity:awake()
  end
  self:emit('entity_added', entity)
end

---removes entity
---@param entity Entity
function Entities:removeEntity(entity)
  assert(self.entitiesHash[entity:getName()], 'Attempting to remove entity that is not in entities collection')
  lume.remove(self.entities, entity)
  lume.remove(self.entitiesHash, entity)
  lume.remove(self.entitiesYSort, entity)
  lume.remove(self.entitiesBackgroundDraw, entity)
  entity:disconnect('entity_destroyed', self)
  entity:removed()
  self:emit('entity_removed', entity)
  entity:release()
end

---sets how large the map is in tile size
---this enables querying for tiles via x and y coordinate
---also up the tile entities collection
---note that this just discards the current tile Entities
---@param mapWidth integer
---@param mapHeight integer
---@param layerAmount integer
function Entities:setUpTileEntityCollection(mapWidth, mapHeight, layerAmount)
  self.mapWidth = mapWidth
  self.mapHeight = mapHeight
  self.tileEntities = { }
  for i = 1, layerAmount do
    self.tileEntities[i] = { }
  end
end

---add tile entity
---@param tileEntity Tile
function Entities:addTileEntity(tileEntity)
  assert(tileEntity:isTile(), 'Non tile entities should be added via Entities:addEntity')
  local tileIndex = (tileEntity.tileIndexY - 1) * self.mapWidth + tileEntity.tileIndexX
  self.tileEntities[tileEntity.layer][tileIndex] = tileEntity
  tileEntity:connect('entity_destroyed', self, 'onTileEntityDestroyed')
  tileEntity:awake()
  self:emit('tile_entity_added', tileEntity)
end

---remove tile entity by map index
---@param x integer|Tile
---@param y integer?
---@param layer integer?
function Entities:removeTileEntity(x, y, layer)
  if type(x) == 'table' then
    ---@type Tile
    local tileEntity = x
    x = tileEntity.tileIndexX
    y = tileEntity.tileIndexY
    layer =  tileEntity.layer
  end
  local tileIndex = (y - 1) * self.mapWidth + x
  local tileEntity = self.tileEntities[layer][tileIndex]
  if tileEntity then
    self.tileEntities[layer][tileIndex] = nil
    tileEntity:removed()
    self:emit('tile_entity_removed', tileEntity)
    tileEntity:release()
  end
end

---get entity by name
---@param name string
---@return Entity
function Entities:getByName(name)
  return self.entitiesHash[name]
end

--- get tile entity by map index
---@param x integer
---@param y integer
---@param layer integer
---@return Tile?
function Entities:getTileEntity(x, y, layer)
  local tileIndex = (y - 1) * self.mapWidth + x
  return self.tileEntities[layer][tileIndex]
end

--- get the top tile at a given position
---@param x number
---@param y number
---@return Tile?
function Entities:getTopTileEntity(x, y)
  x, y = math.floor(x), math.floor(y)
  x = x + 1
  y = y + 1
  local tileIndex = (y - 1) * self.mapWidth * x
  for layer = lume.count(self.tileEntities), 1, -1 do
    local tileEntity = self.tileEntities[layer][tileIndex]
    if tileEntity then
      return tileEntity
    end
  end
  return nil
end

--- checks if the given tile at given coordinates is the top tile
---@param tile Tile
function Entities:isTopTile(tile)
  local topLayer = lume.count(self.tileEntities)
  local tileIndex = (tile.tileIndexY - 1) * self.mapWidth + (tile.tileIndexX)
  for layer = topLayer, 1, -1 do
    local tileEntity = self.tileEntities[layer][tileIndex]
    if tileEntity then
      return tile == tileEntity
    end
  end
  return false
end

function Entities:update()
  self.player:update()
  for _, entity in ipairs(self.entities) do
    if entity ~= self.player then
      entity:update()
    end
  end
end

---draws tile entities
---if given a cull rect, will only draw tiles within the cull rectangle
---@param x number?
---@param y number?
---@param w integer?
---@param h integer?
function Entities:drawTileEntities(x, y, w, h)
  if x == nil then
    for i, layer in ipairs(self.tileEntities) do
      for j, tile in pairs(self.tileEntities[i]) do
        if self.tileEntities[i][j] then
          self.tileEntities[i][j]:draw()
        end
      end
    end
  else
    x = math.floor(x / Consts.GRID_SIZE)
    y = math.floor(y / Consts.GRID_SIZE)
    w = math.ceil(w / Consts.GRID_SIZE)
    h = math.ceil(h / Consts.GRID_SIZE)
    for i = x, x + w, 1 do
      for j = y, y + h, 1 do
        for layerIndex , layer in ipairs(self.tileEntities) do
          local tileEntity = self:getTileEntity(i + 1, j + 1, layerIndex)
          if tileEntity then
            tileEntity:draw()
          end
        end
      end
    end
  end
end

-- draws all the non tile entities
function Entities:drawEntities(x,y,w,h)
  local shouldCull = x ~= nil
  -- draw the background entities first
  if shouldCull then
    for _, entity in ipairs(self.entitiesBackgroundDraw) do
      if rect.isIntersecting(x,y,w,h,  entity.x, entity.y, entity.w, entity.h) then
        drawEntity(entity)
      end
    end
  else
    lume.each(self.entitiesBackgroundDraw, drawEntity)
  end

  -- draw the ysort entitites
  table.sort(self.entitiesYSort, ySort)
  if shouldCull then
    for _, entity in ipairs(self.entitiesYSort) do
      if rect.isIntersecting(x,y,w,h, entity.x, entity.y, entity.w, entity.h) then
        drawEntity(entity)
      end
    end
  else
    lume.each(self.entitiesYSort, drawEntity)
  end
end

function Entities:debugDrawEntities(x,y,w,h, entDebugDrawFlags)
  local shouldCull = x ~= nil
  -- draw the background entities first
  if shouldCull then
    for _, entity in ipairs(self.entitiesBackgroundDraw) do
      if rect.isIntersecting(x,y,w,h,  entity.x, entity.y, entity.w, entity.h) then
        entity:debugDraw(entDebugDrawFlags)
      end
    end
  else
    lume.each(self.entitiesBackgroundDraw, function(entity) entity:debugDraw() end)
  end

  -- draw the ysort entitites
  table.sort(self.entitiesYSort, ySort)
  if shouldCull then
    for _, entity in ipairs(self.entitiesYSort) do
      if rect.isIntersecting(x,y,w,h, entity.x, entity.y, entity.w, entity.h) then
        entity:debugDraw(entDebugDrawFlags)
      end
    end
  else
    lume.each(self.entitiesYSort, function(entity) entity:debugDraw() end)
  end
end

--- query entities by group
--- table can be returned to TablePool
---@param group string
---@return Entity[]
function Entities:queryByGroup(group)
  local table = TablePool.obtain()
  for _, entity in ipairs(self.entities) do
    if entity:getGroup() == group then
      lume.push(table, entity)
    end
  end

  return table
end

-- signal callbacks

---callback when an entity is destroyed
---@param entity Entity
function Entities:onEntityDestroyed(entity)
  self:removeEntity(entity)
end

---callback when a tile entity is destroyed. 
---@param tileEntity Tile
function Entities:onTileEntityDestroyed(tileEntity)
  self:removeTileEntity(tileEntity.tileIndexX, tileEntity.tileIndexY, tileEntity.layer)
end

---call back when an entity is spawned
function Entities:onSpawnedEntity(entity)
  self:addEntity(entity)
end

return Entities