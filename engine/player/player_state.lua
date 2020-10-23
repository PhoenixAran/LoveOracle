local Class = require 'lib.class'
local PlayerStateParameters = require 'engine.player.player_state_parameters'

local PlayerState = Class {
  init = function(self)
    self.active = false
    self.player = nil
    self.playerController = nil
    self.stateParameters = PlayerStateParameters()
  end
}

function PlayerState:getType()
  return 'playerstate'
end

function PlayerState:isActive()
  return self.active
end

-- "Virtual" methods
function PlayerState:onBegin(previousState) end

function PlayerState:onEnd(newState) end

function PlayerState:onEnterRoom() end

function PlayerState:onLeaveRoom() end

function PlayerState:onHurt() end

function PlayerState:onInterruptWeapons() end

function PlayerState:update(dt) end

function PlayerState:canTransitionFromState(state)
  return true
end

function PlayerState:canTransitionToState(state)
  return true
end

-- beginState and endState
function PlayerState:beginState(player, previousState)
  self.active = true
  self.player = player
  self:onBegin(previousState)
end

function PlayerState:endState(newState)
  this.active = false
  self:onEnd(newState)
end

return PlayerState