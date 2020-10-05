local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local PlayerStateParameters = require 'engine.player.player_state_parameters'

local defaultPlayerStateParameters = PlayerStateParameters()

local PlayerStateMachine = Class { _includes = SignalObject,
  init = function(self, player)
    SignalObject.init(self)
    self.player = player
    self.previousState = nil
    self.currentState = nil
  end
}

-- states
-- TODOMAYBE - instead of nil should there just be an emptystate?
function PlayerStateMachine:canTransitionTo(newState)
  if newState ~= nil then
    -- lazy initialize
    newState.player = self.player
    newState.controller = self
  end
  if self.currentState ~= nil and not self.currentState:canTransitionToState(newState) then
    return false
  end
  if newState ~= nil and not self.newState:canTransitionFromState(self.currentState) then
    return false
  end
  return true
end

function PlayerStateMachine:beginState(newState)
  if self:canTransitionToState(newState) then
    if newState ~= self.currentState then
      self:forceBeginState(newState)
    end
    return true
  else
    return false
  end
end

function PlayerStateMachine:forceBeginState(newState)
  -- end the current state
  self.previousState = self.currentState
  if self.currentState ~= nil then
    self.currentState:endState(newState)
  end
  
  --begin the new state
  self.currentState = newState
  if self.currentState ~= nil then
    self.currentState = self
  end
end

function PlayerStateMachine:update(dt)
  if self.currentState ~= nil then
    self.currentState:update(dt)
    if not self.active then
      self.currentState = nil
    end
  else
    self.currentState = nil
  end
end

function PlayerStateMachine:getStateParameters()
  if self.currentState ~= nil then return self.currentState.stateParameters end
  return defaultPlayerStateParameters
end

function PlayerStateMachine:isActive()
  return self.state ~= nil and self.state.active
end

function PlayerStateMachine:clear()
    self.previousState = nil
    self.currentState = nil
end

return PlayerStateMachine