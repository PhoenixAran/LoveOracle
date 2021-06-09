local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'
local TILE_SIZE = 16

local Entities = Class { __includes = SignalObject,
  init = function(self, gameScreen, camera, player)
    SignalObject.init(self)
    
    self:signal('entityAdded')
    self:signal('entityRemoved')
    
    self:signal('tileEntityAdded')
    self:signal('tileEntityRemoved')

    self.gameScreen = gameScreen

    self.player = player
    self.entities = { }
    self.entitiesHash = { }
    self.entitiesDraw = { }

    self.mapSizeX = nil
    self.mapSizeY = nil
    self.tileEntities = { }
  end
}

local function ySort(entityA, entityB)
  local ax, ay = entityA:getPosition()
  local bx, by = entityB:getPosition()
  return by < ay
end

function Entities:setPlayer(player)
  assert(not self.entitiesHash[player:getName()])
  self.player = player
  lume.push(self.entities, player)
  self.entitiesHash[self.player:getName()] = player
  lume.push(self.entitiesDraw, player)
end

function Entities:getPlayer()
  return self.player
end

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

function Entities:removeEntity(entity)
  assert(self.entitiesHash[entity:getName()], 'Attempting to remove entity that is not in entities collection')
  lume.remove(self.entities, entity)
  lume.remove(self.entitiesHash, entity)
  lume.remove(self.entitiesDraw, entity)
  entity:removed()
  self:emit('entityRemoved', entity)
  entity:release()
end


-- sets how large the map is in tile size
-- this enables querying for tiles via x and y coordinate
-- also up the tile entities collection
-- note that this just discards the current tile Entities
function Entities:setUpTileEntityCollection(sizeX, sizeY, layerAmount)
  self.mapSizeX = sizeX
  self.mapSizeY = sizeY
  self.tileEntities = { } 
  for i = 1, layerAmount do
    self.tileEntities[i] = { }
  end
end

function Entities:addTileEntity(tileEntity)
  assert(tileEntity:isTile())
  local tileIndex = (tileEntity.tileIndexX - 1) * self.mapSizeY + tileEntity.tileIndexY
  self.tileEntities[tileEntity.layer][tileIndex] = tileEntity
  lume.push(self.tileEntities[tileEntity.layer], tileEntity)
  self:emit('tileEntityAdded', tileEntity)
end

function Entities:removeTileEntity(layer, x, y)
  local tileIndex = (x - 1) * self.mapSizeY + y
  local tileEntity = self.tileEntities[layer][tileIndex]
  if tileEntity then
    self.tileEntities[layer][tileIndex] = nil
    self:emit('tileEntityRemoved', tileEntity)
    tileEntity:release()
  end
end


-- sets how large the map is in tile size
-- this enables querying for tiles via x and y coordinate
-- also up the tile entities collection
-- note that this just discards the current tile Entities
function Entities:setUpTileEntityCollection(sizeX, sizeY, layerAmount)
  self.mapSizeX = sizeX
  self.mapSizeY = sizeY
  self.tileEntities = { } 
  for i = 1, layerAmount do
    self.tileEntities[i] = { }
  end
end

function Entities:addTileEntity(tileEntity)
  assert(tileEntity:isTile())
  local tileIndex = (tileEntity.tileIndexX - 1) * self.mapSizeY + tileEntity.tileIndexY
  self.tileEntities[tileEntity.layer][tileIndex] = tileEntity
  lume.push(self.tileEntities[tileEntity.layer], tileEntity)
  self:emit('tileEntityAdded', tileEntity)
end

function Entities:removeTileEntity(layer, x, y)
  local tileIndex = (x - 1) * self.mapSizeY + y
  local tileEntity = self.tileEntities[layer][tileIndex]
  self.tileEntities[layer][mapCoords] = nil
  self:emit('tileEntityRemoved', tileEntity)
end

function Entities:getByName(name)
  return self.entitiesHash[name]
end

function Entities:getTileEntity(layer, x, y)
  local tileIndex = (x - 1) * self.mapSizeY + y
  return self.tileEntities[layer][tileIndex]
end

function Entities:update(dt)
  self.player:update(dt)
  for _, entity in ipairs(self.entities) do
    if entity ~= self.player then
      entity:update(dt)
    end
  end
end

-- draws tile entities
-- if given a cull rect, will only draw tiles within the cull rectangle
function Entities:drawTileEntities(x, y, w, h)
  if x == nil then
    for _, layer in ipairs(self.tileEntities) do
      lume.each(layer, 'draw')
    end
  else
    x = math.floor(x / TILE_SIZE)
    y = math.floor(y / TILE_SIZE)
    w = math.ceil(w / TILE_SIZE) + 1
    h = math.ceil(h / TILE_SIZE) + 1
    for i = x, x + w, 1 do
      for j = y, y + h, 1 do
        for layerIndex , layer in ipairs(self.tileEntities) do
          local tileEntity = self:getTileEntity(layerIndex, i + 1, j + 1)
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
  lume.each(self.entitiesDraw, 'draw')
end

return Entities