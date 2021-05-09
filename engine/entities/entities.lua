local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'

local Entities = Class { __includes = SignalObject,
  init = function(self, gameScreen, camera, player)
    SignalObject.init(self)
    
    self:signal('entityAdded')
    self:signal('entityRemoved')
    
    self:signal('tileEntityAdded')
    self:signal('tileEntityRemoved')

    self.camera = camera
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
  return ay - by
end

function Entities:setCamera(camera)
  self.camera = camera
end

function Entities:getCamera()
  return self.camera
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
  self.entitiesHash[entity] = entity
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
  if self.camera then
    self.camera:update(dt)
    self.camera:follow(self.player:getPosition())
  end
end

function Entities:draw()
  if self.camera then
    self.camera:attach()
  end
  -- TODO only draw if entity / tile is within the camera bounds
  for i, layer in ipairs(self.tileEntities) do
    lume.each(layer, 'draw')
  end
  lume.sort(self.entitiesDraw, ySort)
  lume.each(self.entitiesDraw, 'draw')
  if self.camera then
    self.camera:detach()
  end
end

return Entities