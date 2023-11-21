local Class = require 'lib.class'
local lume = require 'lib.lume'
local PlayerState = require 'engine.player.player_state'

---@class PlayerHitstunState : PlayerState
---@field combat Combat
local PlayerHitstunState = Class { __includes = PlayerState,
  ---@param self PlayerHitstunState
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

---@param previousState PlayerState
function PlayerHitstunState:onBegin(previousState)
  self.combat = self.player.combat
  self.player:interruptItems()
  self.player.sprite:play('idle')
  assert(self.player.combat, 'Player does not have combat component')
end

function PlayerHitstunState:update(dt)
  if not self.combat:inHitstun() then
    self:endState()
  end
end

---@param newState PlayerState
function PlayerHitstunState:onEnd(newState)
  self.combat = nil
end

return PlayerHitstunState