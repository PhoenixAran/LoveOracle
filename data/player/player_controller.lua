local Class = require 'lib.class'
local PlayerStateParameters = require 'data.player.player_state_parameters'

local PlayerController = Class {
  init = function(self, player)
    self.player = player
    self.previousState = nil
    self.currentState = nil
  end
}

-- states
-- todo instead of nil should there just be an emptystate?
function PlayerController:canTransitionTo(newState)
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

function PlayerController:beginState(newState)
  if self:canTransitionToState(newState) then
    if newState ~= self.currentState then
      self:forceBeginState(newState)
    end
    return true
  else
    return false
  end
end

function PlayerController:forceBeginState(newState)
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

function PlayerController:update(dt)
  if self.currentState ~= nil then
    self.currentState:update(dt)
    if not self.active then
      self.currentState = nil
    end
  else
    self.currentState = nil
  end
end

function PlayerController:getStateParameters()
  if self.currentState ~= nil then return self.currentState.stateParameters end
  return PlayerStateParameters()
end