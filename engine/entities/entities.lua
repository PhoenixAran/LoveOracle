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

function Entities:setPlayer(player)
  assert(not self.entitiesHash[player:getName()])
  self.player = player
  lume.push(self.entities, player)
  lume.push(self.entitiesHash[self.player:getName()], player)
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
  for _, entity in self.entities do
    if entity ~= self.player then
      entity:update(dt)
    end
  end
  self.camera:update(dt)
end

function Entities:draw()
  table.sort(self.entitiesDraw, function(a, b) 
    local ax, ay = a:getPosition()
    local bx, by = b:getPosition()
    return ay - by
  end)
  lume.each(self.entitiesDraw, 'draw')
end