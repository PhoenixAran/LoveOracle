local Class = require 'lib.class'
local lume = require 'lib.lume'
local PlayerState = require 'engine.player.player_state'

local PlayerHitstunState = Class { __includes = PlayerState,
  init = function(self)
    PlayerState.init(self)
    self.combat = nil

    self.stateParameters.canJump = false
    self.stateParameters.canWarp = false
    self.stateParameters.canLedgeJump = false
    self.stateParameters.canControlOnGround = false
    self.stateParameters.canControlInAir = false
    self.stateParameters.canPush = false
    self.stateParameters.canUseWeapons = false
    self.stateParameters.canRoomTransition = false
    self.stateParameters.canStrafe = false
  end
}

function PlayerHitstunState:getType()
  return 'player_hitstun_state'
end

function PlayerHitstunState:onBegin(previousState)
  self.combat = self.player.combat
  self.player:interruptWeapons()
  self.player.sprite:play('idle')
  assert(self.combat, 'Player does not have combat component')
end

function PlayerHitstunState:update(dt)
  if not self.combat:inHitstun() then
    self:endState()
  end
end

function PlayerHitstunState:onEnd(newState)
  self.combat = nil
end


return PlayerHitstunState