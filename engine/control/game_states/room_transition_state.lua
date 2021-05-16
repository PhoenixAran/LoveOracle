local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'
local Direction4 = require 'engine.enums.direction4'
local Tween = require 'lib.tween'

local RoomTransitionState = Class { __includes = GameState,
  init = function(self, currentRoom, newRoom, direction4)
    GameState.init(self)
    self.currentRoom = currentRoom
    self.newRoom = newRoom
    self.direction4 = direction4
    self.playerTween = nil
    self.cameraTween = nil
  end
}

function RoomTransitionState:getType()
  return 'room_transition_state'
end

function RoomTransitionState:onBegin()
  
end

function RoomTransitionState:onEnd()

end

function RoomTransitionState:update(dt)

end

function RoomNormalState:draw()

end

return RoomTransitionState