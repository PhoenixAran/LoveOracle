local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local Singletons = require 'engine.singletons'
local Tween = require 'lib.tween'
local rect = require 'engine.math.rectangle'
local DamageInfo = require 'engine.entities.damage_info'
local Camera = require 'engine.camera'
local SimpleStateMachine = require 'engine.utils.simple_state_machine'

local RespawnState = {
  DeathAnimation = 0,
  ViewPanning = 1,
  Delay = 2
}

---@class PlayerRespawnDeathState : PlayerState
---@field waitForAnimation boolean
---@field cameraSubject any
---@field cameraTween any
---@field lastCameraX number
---@field lastCameraY number
---@field respawnDamageInfo DamageInfo
---@field subStateMachine SimpleStateMachine
local PlayerRespawnDeathState = Class { __includes = PlayerState,
  ---@param self PlayerRespawnDeathState
  init = function(self)
    PlayerState.init(self)
    self.waitForAnimation = true

    self.stateParameters.canStrafe = true
    self.stateParameters.canControlOnGround = false
    self.stateParameters.canControlInAir = false
    self.stateParameters.hitboxCollisions = false
    self.stateParameters.canUseWeapons = false

    self.respawnDamageInfo = DamageInfo({
      damage = 2,
      hitstunTime = 12,
      intangibilityTime = 44,
    })


    -- configure the sub-state machine
    self.subStateMachine = SimpleStateMachine(self, RespawnState)
    self.subStateMachine:addState(RespawnState.DeathAnimation)
                        :onUpdate(self.onUpdateDeathAnimationState)
                        :onEnd(self.onEndDeathAnimationState)
    self.subStateMachine:addState(RespawnState.ViewPanning)
                        :onBegin(self.onBeginViewPanningState)
                        :onUpdate(self.onUpdateViewPanningState)
                        :onEnd(self.onEndViewPanningState)
    self.subStateMachine:addState(RespawnState.Delay)
                        :onBegin(self.onBeginDelayState)
                        :addEvent(16, function()
                          self:endState()
                        end)
  end
}

function PlayerRespawnDeathState:getType()
  return 'player_respawn_death_state'
end


function PlayerRespawnDeathState:onEndDeathAnimationState()
  self.player:setVisible(false)
end

function PlayerRespawnDeathState:onBeginViewPanningState()
  self.player:respawn()
  self.player:setVisible(true)
  self.respawnState = RespawnState.ViewPanning
end

function PlayerRespawnDeathState:onUpdateViewPanningState()
  -- TODO wait until camera stops moving towards the player
  self.subStateMachine:nextState()
end

function PlayerRespawnDeathState:onEndViewPanningState()
  self.respawnState = RespawnState.Delay
end

function PlayerRespawnDeathState:shouldWaitForCurrentAnimation()
  if not self.waitForAnimation then
    return false
  end

  local sprite = self.player.sprite
  local currentAnimation = sprite and sprite.currentAnimation
  return currentAnimation ~= nil and currentAnimation.loopType == 'once'
end

function PlayerRespawnDeathState:onUpdateDeathAnimationState()
  if (not self:shouldWaitForCurrentAnimation()) or self.player.sprite:isCompleted() then
    self.subStateMachine:nextState()
  end
end

function PlayerRespawnDeathState:onBeginDelayState()
  self.respawnState = RespawnState.Delay
  self.player:setVisible(true)
  self.player:hurt(self.respawnDamageInfo)
end


-- player respawn state 
---@param previousState PlayerState
function PlayerRespawnDeathState:onBegin(previousState)
  self.respawnState = RespawnState.DeathAnimation
  self.stateParameters.canStrafe = true
  self.stateParameters.canControlOnGround = false
  self.stateParameters.canControlInAir = false
  self.stateParameters.canJump = false

  self.player:setVector(0, 0)
  self.player:interruptItems()
  self.player:disableCollisions()

  self.subStateMachine:initializeOnState(RespawnState.DeathAnimation)
end

function PlayerRespawnDeathState:update()
  self.subStateMachine:update()
end

function PlayerRespawnDeathState:onEnd(newState)
  self.player:enableCollisions()
  self.player = nil
  self.camera = nil
end

return PlayerRespawnDeathState
