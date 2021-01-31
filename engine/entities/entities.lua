local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'

local Entities = Class { __includes = SignalObject,
  init = function(self, gameScreen, camera, player)
    SignalObject.init(self)
    
    self:signal('entityAdded')
    self:signal('entityRemoved')
    
    self.camera = camera
    self.gameScreen = gameScreen
    self.player = player
    self.entities = { }
    self.entitiesHash = { }
    self.entitiesDraw = { }
  end
}

local function ySort(entityA, entityB)
  local ax, ay = entityA:getPosition()
  local bx, by = entityB:getPosition()
  return ay - by
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

function Entities:getByName(name)
  return self.entitiesHash[name]
end

function Entities:update(dt)
  self.player:update(dt)
  for _, entity in ipairs(self.entities) do
    if entity ~= self.player then
      entity:update(dt)
    end
  end
  --self.camera:update(dt)
end

function Entities:draw()
  lume.sort(self.entitiesDraw, ySort)
  lume.each(self.entitiesDraw, 'draw')
end

return Entities