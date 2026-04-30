local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Direction4 = require 'engine.enums.direction4'
local GameState = require 'engine.control.game_state'
local Singletons = require 'engine.singletons'
local GameConfig = require 'game_config'

---@class MenuTransitonState : GameState
---@field oldMenuState BaseMenuState the menu state we are transitioning from
---@field newMenuState BaseMenuState the menu state we are transitioning to
---@field direction Direction4 the direction of the transition. from old -> new is right. new <- old is left
---@field currentRoomState GameState? the current room state that the menu is being opened from. Used to draw the room in the background during the transition
---@field translateX number
---@field originalOldMenuDrawRoomState boolean
---@field originalNewMenuDrawRoomState boolean
local MenuTransitionState = Class {
  init = function(self, oldMenuState, newMenuState, direction, currentRoomState)
    assert(direction == Direction4.left or direction == Direction4.right, 'Only left and right transitions are supported')
    GameState.init(self)
    self.oldMenuState = oldMenuState
    self.newMenuState = newMenuState
    self.currentRoomState = currentRoomState
    self.direction = direction
    self.translateX = 0
  end
}

function MenuTransitionState:getType()
  return 'menu_transition_state'
end

function MenuTransitionState:onBegin()
  self.originalNewMenuDrawRoomState = self.oldMenuState.drawLastRoomState
  self.drawLastRoomState = false
  self.originalOldMenuDrawRoomState = self.newMenuState.drawLastRoomState
  self.newMenuState.drawLastRoomState = false
  

  if self.direction == Direction4.left then
  else
  end
end

function MenuTransitionState:update()
  
end

function MenuTransitionState:draw()
  self.currentRoomState:draw()
  if self.direction == Direction4.left then

  else
    -- draw our old menu state going to the left

    -- draw our new menu state coming in from the right
  end
end

function MenuTransitionState:onEnd()
  Singletons.gameControl:pushState(self.newMenuState)
end

return MenuTransitionState