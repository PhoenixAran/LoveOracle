local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local Singletons = require 'engine.singletons'
local Tween = require 'lib.tween'
local rect = require 'engine.math.rectangle'
local DamageInfo = require 'engine.entities.damage_info'
local Camera = require 'engine.camera'

local RespawnState = {
  DeathAnimation = 0,
  ViewPanning = 1,
  Delay = 2
}

---@class PlayerRespawnDeathState : PlayerState
---@field waitForAnimation boolean
---@field respawnState integer
---@field cameraSubject any
---@field cameraTween any
---@field lastCameraX number
---@field lastCameraY number
---@field respawnDamageInfo DamageInfo
local PlayerRespawnDeathState = Class { __includes = PlayerState,
  ---@param self PlayerRespawnDeathState
  init = function(self)
    PlayerState.init(self)

    self.waitForAnimation = true
    self.respawnState = RespawnState.DeathAnimation
    self.stateParameters.canStrafe = true
    self.stateParameters.canControlOnGround = false
    self.stateParameters.canControlInAir = false
    self.stateParameters.hitboxCollisions = false

    self.respawnDamageInfo = DamageInfo({
      damage = 2,
      hitstunTime = 12,
      intangibilityTime = 44,
    })
  end
}

function PlayerRespawnDeathState:getType()
  return 'player_respawn_death_state'
end

function PlayerRespawnDeathState:endDeathAnimationState()
end

function PlayerRespawnDeathState:startViewPanningState()
  self.player:respawn()
  self.player:setVisible(true)
  self.respawnState = RespawnState.ViewPanning
end

function PlayerRespawnDeathState:endViewPanningState()
  self.respawnState = RespawnState.Delay
end

function PlayerRespawnDeathState:startDelayState()
  self.respawnState = RespawnState.Delay
  self.player:setVisible(true)
  self.player:hurt(self.respawnDamageInfo)
end

function PlayerRespawnDeathState:endDelayState()
  self:endState()
end

function PlayerRespawnDeathState:update(dt)
  if self.respawnState == RespawnState.DeathAnimation then
    if (not self.waitForAnimation) or self.player.sprite:isCompleted() then
      self.player:setVisible(false)
      self:endDeathAnimationState()
      self:startViewPanningState()
    end
  elseif self.respawnState == RespawnState.ViewPanning then
    self:endViewPanningState()
    self:startDelayState()
  elseif self.respawnState == RespawnState.Delay then
    if not self.player:inHitstun() then
      self:endDelayState()
    end
  end
end

---@param previousState PlayerState
function PlayerRespawnDeathState:onBegin(previousState)
  self.respawnState = RespawnState.DeathAnimation
  self.stateParameters.canStrafe = true
  self.stateParameters.canControlOnGround = false
  self.stateParameters.canControlInAir = false
  self.stateParameters.canJump = false
end

function PlayerRespawnDeathState:onEnd(newState)
  self.player = nil
  self.camera = nil
end

return PlayerRespawnDeathState
