local Class = require 'lib.class'
local PlayerStateParameters = require 'engine.player.player_state_parameters'

---@class PlayerState
---@field active boolean
---@field player Player
---@field stateMachine PlayerStateMachine
---@field stateParameters PlayerStateParameters
---@field init function
local PlayerState = Class {
  init = function(self)
    self.active = false
    self.player = nil
    self.playerController = nil
    self.stateParameters = PlayerStateParameters()
  end
}

function PlayerState:getType()
  return 'player_state'
end

function PlayerState:isActive()
  return self.active
end

-- "Virtual" methods

---@param previousState PlayerState
function PlayerState:onBegin(previousState) end

---@param newState PlayerState?
function PlayerState:onEnd(newState) end

function PlayerState:onEnterRoom() end

function PlayerState:onLeaveRoom() end

function PlayerState:onHurt() end

function PlayerState:onInterruptItems() end

function PlayerState:update() end

---@param state PlayerState
---@return boolean
function PlayerState:canTransitionFromState(state)
  return true
end

---@param state PlayerState?
---@return boolean
function PlayerState:canTransitionToState(state)
  return true
end

---@param player Player
---@param previousState PlayerState
function PlayerState:beginState(player, previousState)
  self.active = true
  self.player = player
  self:onBegin(previousState)
end

---@param newState PlayerState?
function PlayerState:endState(newState)
  self.active = false
  self:onEnd(newState)
end

return PlayerState