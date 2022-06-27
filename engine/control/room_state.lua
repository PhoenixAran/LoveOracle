local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'

---@class RoomState
---@field active boolean
---@field visible boolean
---@field roomControl RoomControl
---@field init function
local RoomState = Class { _includes = SignalObject,
  init = function(self)
    SignalObject.init(self)
    self.active = false
    self.visible = false
    self.roomControl = nil
  end
}

function RoomState:getType()
  return 'room_state'
end

function RoomState:onBegin() end

function RoomState:onEnd() end

---@param roomControl RoomControl
function RoomState:begin(roomControl)
  if not self.active then
    self.active = true
    self.roomControl = roomControl
    self:onBegin()
  end
end

function RoomState:endState()
  if self.active then
    self:onEnd()
    self.active = false
    self.roomControl = nil
  end
end

function RoomState:update(dt) end

function RoomState:draw() end

return RoomState