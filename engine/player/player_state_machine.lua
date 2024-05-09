local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local PlayerStateParameters = require 'engine.player.player_state_parameters'
local Pool = require 'engine.utils.pool'

---@class PlayerStateMachine : SignalObject
---@field previousState PlayerState | PlayerEnvironmentState | nil
---@field currentState PlayerState | PlayerEnvironmentState | nil
local PlayerStateMachine = Class { _includes = SignalObject,
  ---@param self PlayerStateMachine
  ---@param player Player
  init = function(self, player)
    SignalObject.init(self)
    self.player = player
    self.previousState = nil
    self.currentState = nil
  end
}

function PlayerStateMachine:getType()
  return 'player_state_machine'
end

---@param player Player
function PlayerStateMachine:setPlayer(player)
  self.player = player
end

---@return PlayerState?|PlayerEnvironmentState?
function PlayerStateMachine:getCurrentState()
  if self.currentState == nil or not self.currentState.active then
    return nil
  end
  return self.currentState
end

---@return PlayerState?|PlayerEnvironmentState?
function PlayerStateMachine:getPreviousState()
  return self.previousState
end

--- checks if player can transition to the given state
---@param newState PlayerState?|PlayerEnvironmentState?
function PlayerStateMachine:canTransitionTo(newState)
  if newState ~= nil then
    -- lazy initialize
    newState.player = self.player
    newState.stateMachine = self
  end
  if self.currentState ~= nil and not self.currentState:canTransitionToState(newState) then
    return false
  end
  if newState ~= nil and not newState:canTransitionFromState(self.currentState) then
    return false
  end
  return true
end


---@param newState PlayerState|PlayerEnvironmentState|nil
function PlayerStateMachine:beginState(newState)
  if self:canTransitionTo(newState) then
    if newState ~= self.currentState then
      self:forceBeginState(newState)
    end
    return true
  else
    return false
  end
end

---@param newState PlayerState|PlayerEnvironmentState|nil
function PlayerStateMachine:forceBeginState(newState)
  -- end the current state
  self.previousState = self.currentState
  if self.currentState ~= nil then
    self.currentState:endState(newState)
  end

  --begin the new state
  self.currentState = newState
  if self.currentState ~= nil then
    self.currentState.stateMachine = self
    self.currentState:beginState(self.player, self.previousState)
    if not self.currentState:isActive() then
      self.previousState = self.currentState
      self.currentState = nil
    end
  end
end

function PlayerStateMachine:update(dt)
  if self.currentState ~= nil then
    self.currentState:update(dt)
    if not self.currentState.active then
      self.currentState = nil
    end
  else
    self.currentState = nil
  end
end

---@return PlayerStateParameters
function PlayerStateMachine:getStateParameters()
  if self.currentState ~= nil then return self.currentState.stateParameters end
  return PlayerStateParameters.EmptyStateParameters
end


function PlayerStateMachine:isActive()
  return self.currentState ~= nil and self.currentState:isActive()
end

function PlayerStateMachine:reset()
  self.player = nil
  self.previousState = nil
  self.currentState = nil
end

if Pool then
  Pool.register('player_state_machine', PlayerStateMachine)
end

return PlayerStateMachine