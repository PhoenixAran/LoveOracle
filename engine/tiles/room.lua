local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'

local Room = Class { __includes = SignalObject,
  init = function(self, roomData)
    SignalObject.init(self) 
    self:signal('roomTransitionRequested')
    self:signal('mapTransitionRequested')


    -- immutable room data read from disk
    self.staticRoomData = roomData
    -- mutable room data that can save persistant state (such as objects being broken and stuff)
    self.sessionRoomData = roomData:clone()

    -- ids of entities that were killed 
    self.destroyedEntities = { }
    -- ids of tile entities that were destroyed
    self.destroyedTileEntities = { }
  end
}

function Room:resetState()
  self.sessionRoomData = staticRoomData:clone()
end

function Room:load(entities)
  -- add tiles
  -- add objects
  -- add entities
end

-- this will only keep track of the entities declared in room data
function Room:onEntityDestroyed()
  -- If it's a tile entity, record it to list of destroyed entitites
end

-- pass signal from RoomEdge to whoever is listening
function Room:onRequestTransitionRequest()
  self:emit('roomTransitionRequested')
end

-- pass signal from MapLoadingZone to whoever is listening
function Room:onMapTransitionRequested()
  self:emit('mapTransitionRequested')
end

function Room:getType()
  return 'room'
end

function Room:getRoomData()
  return self.roomData
end

return Room