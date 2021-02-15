local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'

local Room = Class { __includes = SignalObject,
  init = function(self, roomData)
    SignalObject.init(self)
    self.roomData = roomData
  end
}

function Room:getType()
  return 'room'
end

function Room:getRoomData()
  return self.roomData
end

return Room