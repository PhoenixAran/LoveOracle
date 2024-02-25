local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local PlayerMotionType = require 'engine.player.player_motion_type'
local PlayerEnvironmentState = require 'engine.player.environment_states.player_environment_state'

local function createSplashEffect()
  -- TODO
end


---@class PlayerSwimEnvironmentState : PlayerEnvironmentState
---@field isSubmerged boolean
---@field submergedTimer integer
---@field submergedDuration integer
---@field silentBeginning boolean
local PlayerSwimEnvironmentState = Class { __includes = PlayerEnvironmentState,
  ---@param self PlayerSwimEnvironmentState
  init = function(self)
    PlayerEnvironmentState.init(self)

    self.submergedDuration = 128
    self.isSubmerged = false
    self.submergedTimer = 0
    self.silentBeginning = false

    self.stateParameters.canJump = false
    self.stateParameters.canPush = false
    self.stateParameters.canUseWeapons = false

    self.motionSettings.speed = .085
    self.motionSettings.slippery = true
    self.motionSettings.acceleration = .33
    self.motionSettings.deceleration = .05
    self.motionSettings.directionSnapCount = 32
  end
}

function PlayerSwimEnvironmentState:getType()
  return 'player_swim_environment_state'
end

function PlayerSwimEnvironmentState:canSwimInCurrentLiquid()
  local skills = self.player:getSkills()
  if self.player:isInLava() then
    return skills.canSwimInLava
  elseif self.player:isInDeepWater() then
    return skills.canSwimInWater
  end

  return false
end


function PlayerSwimEnvironmentState:submerge()
  createSplashEffect()
  self.isSubmerged = true
  self.submergedTimer = self.submergedDuration
  self.stateParameters.interactionCollisions = false
  self.stateParameters.animations.default = 'submerged'
end

function PlayerSwimEnvironmentState:resurface()
  self.isSubmerged = false
  self.stateParameters.interactionCollisions = true
  self.stateParameters.animations.default = 'swim'
end

function PlayerSwimEnvironmentState:drown()
  self.player.sprite:play('drown')
  if self.player:isInLava() then
    self.player.spriteFlasher:flash(24)
  end
  self.player:respawn()
end

---@param previousState PlayerState
function PlayerSwimEnvironmentState:onBegin(previousState)
  self.stateParameters.animations.default = 'swim'
  self.stateParameters.interactionCollisions = true
  self.player:interruptItems()
  self.isSubmerged = false

  if not self.silentBeginning then
    createSplashEffect()

    if not self:canSwimInCurrentLiquid() then
      self:drown()
    end
  else
    self.silentBeginning = false
  end
end

---@param newState PlayerState
function PlayerSwimEnvironmentState:onEnd(newState)
  self.isSubmerged = false
end

function PlayerSwimEnvironmentState:update()
  if self.isSubmerged then
    self.submergedTimed = self.submergedTimer - 1
    if self.submergedTimer <= 0 then
      self:resurface()
    end
  end

  if not self:canSwimInCurrentLiquid() then
    createSplashEffect()
    self:drown()
  end
end


return PlayerSwimEnvironmentState