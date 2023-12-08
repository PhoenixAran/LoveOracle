local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'
local TILE_SIZE = 16

local function drawEntity(ent)
  if ent.isVisible == nil then
    ent:draw()
  end
  if ent:isVisible() then
    ent:draw()
  end
end

---@class Entities : SignalObject
---@field player Player
---@field entities Entity[]
---@field entitiesHash table<string, Entity>
---@field entitiesDraw Entity[]
---@field mapWidth integer
---@field mapHeight integer
---@field tileEntities table<integer, Tile[]>
local Entities = Class { __includes = SignalObject,
  init = function(self, gameScreen, camera, player)
    SignalObject.init(self)
    self:signal('entityAdded')
    self:signal('entityRemoved')
    self:signal('tileEntityAdded')
    self:signal('tileEntityRemoved')

    self.player = player
    self.entities = { }
    self.entitiesHash = { }
    self.entitiesDraw = { }

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
  return by < ay
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
  lume.push(self.entitiesDraw, player)
  if awakeEntity then
    player:awake()
  end
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
  assert(entity:getName(), 'Entity requires name')
  if awakeEntity == nil then awakeEntity = true end
  lume.push(self.entities, entity)
  self.entitiesHash[entity:getName()] = entity
  lume.push(self.entitiesDraw, entity)
  entity:added()
  if awakeEntity then
    entity:awake()
  end
  self:emit('entityAdded', entity)
end

---removes entity
---@param entity Entity
function Entities:removeEntity(entity)
  assert(self.entitiesHash[entity:getName()], 'Attempting to remove entity that is not in entities collection')
  lume.remove(self.entities, entity)
  lume.remove(self.entitiesHash, entity)
  lume.remove(self.entitiesDraw, entity)
  entity:removed()
  self:emit('entityRemoved', entity)
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
  assert(tileEntity:isTile())
  local tileIndex = (tileEntity.tileIndexY - 1) * self.mapWidth + tileEntity.tileIndexX
  self.tileEntities[tileEntity.layer][tileIndex] = tileEntity
  tileEntity:awake()
  self:emit('tileEntityAdded', tileEntity)
end

---remove tile entity by map index
---@param x integer
---@param y integer
---@param layer integer
function Entities:removeTileEntity(x, y, layer)
  local tileIndex = (y - 1) * self.mapWidth + x
  local tileEntity = self.tileEntities[layer][tileIndex]
  if tileEntity then
    self.tileEntities[layer][tileIndex] = nil
    tileEntity:removed()
    self:emit('tileEntityRemoved', tileEntity)
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
  for layer = lume.count(self.tileEntities), 1, -1 do
    local tileEntity = self.tileEntities[layer][tileIndex]
    if tileEntity then
      return tile == tileEntity
    end
  end
  return false
end

function Entities:update(dt)
  self.player:update(dt)
  for _, entity in ipairs(self.entities) do
    if entity ~= self.player then
      entity:update(dt)
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
    x = math.floor(x / TILE_SIZE)
    y = math.floor(y / TILE_SIZE)
    w = math.ceil(w / TILE_SIZE)
    h = math.ceil(h / TILE_SIZE)
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
function Entities:drawEntities()
  lume.sort(self.entitiesDraw, ySort)
  lume.each(self.entitiesDraw, drawEntity)
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


return Entities