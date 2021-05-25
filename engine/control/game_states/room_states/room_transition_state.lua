local Class = require 'lib.class'
local GameState = require 'engine.control.game_state'
local Direction4 = require 'engine.enums.direction4'
local Tween = require 'lib.tween'

local RoomTransitionState = Class { __includes = GameState,
  init = function(self, roomState, currentRoom, newRoom, transitionStyle, direction4)
    GameState.init(self)
    self.transitionStyle = transitionStyle
    self.currentRoom = currentRoom
    self.newRoom = newRoom
    self.direction4 = direction4
    self.player = nil
    self.camera = nil
    self.playerTween = nil
    self.cameraTween = nil
    self.playerTweenCompleted = false
    self.cameraTweenCompleted = false
  end
}

function RoomTransitionState:getType()
  return 'room_transition_state'
end

function RoomTransitionState:onBegin()
  error('Obsolete')
  self.player = self.gameControl:getPlayer()
  self.camera = self.gameControl:getCamera()
end

function RoomTransitionState:update(dt)
  if self.playerTweenCompleted and self.cameraTweenCompleted then
    self:endState()
  end
end

function RoomTransitionState:draw()

end

return RoomTransitionState