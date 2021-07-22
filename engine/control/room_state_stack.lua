local Class = require 'lib.class'
local lume = require 'lib.lume'

local RoomStateStack = Class {
  init = function(self, roomControl)
    self.roomControl = roomControl
    self.states = { }
  end
}

function RoomStateStack:getType()
  return 'game_state_stack'
end

function RoomStateStack:getCurrentState()
  return lume.last(self.states)
end

function RoomStateStack:pushState(roomState)
  roomState:begin(self.roomControl)
  lume.push(self.states, roomState)
end

function RoomStateStack:popState()
  local state = self:getCurrentState()
  state:endState()
  assert(state)
  lume.remove(self.states, state)
  return state
end

return RoomStateStack