local Class = require 'lib.class'
local PlayerEnvironmentState = require 'engine.player.environment_states.player_environment_state'

local function createSplashEffect()
  -- TODO
end


---@class PlayerSwimEnvironmentState : PlayerEnvironmentState
---@field isSubmerged boolean
---@field submergedTimer integer
---@field submergedDuration integer
---@field silentBeginning boolean
---@field isDrowning boolean State will still be active when playersprite is playing the drown animation, so we need to keep track
local PlayerSwimEnvironmentState = Class { __includes = PlayerEnvironmentState,
  ---@param self PlayerSwimEnvironmentState
  init = function(self)
    PlayerEnvironmentState.init(self)

    self.submergedDuration = 128
    self.isSubmerged = false
    self.submergedTimer = 0
    self.silentBeginning = false
    self.isDrowning = false

    self.stateParameters.canJump = false
    self.stateParameters.canPush = false
    self.stateParameters.canUseWeapons = false
    self.stateParameters.animations.move = 'swim'

    self.motionSettings.speed = 30
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
  elseif self.player:isInWater() then
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
  self.stateParameters.animations.move = 'submerged'
end

function PlayerSwimEnvironmentState:resurface()
  self.isSubmerged = false
  self.stateParameters.interactionCollisions = true
  self.stateParameters.animations.default = 'swim'
  self.stateParameters.animations.move = 'swim'
end

function PlayerSwimEnvironmentState:drown()
  if not self.isDrowning then
    self.isDrowning = true
    self.player.sprite:play('drown')
    if self.player:isInLava() then
      self.player.spriteFlasher:flash(24)
    end
    self.player:startRespawnControlState(false)
  end
end

---@param previousState PlayerState
function PlayerSwimEnvironmentState:onBegin(previousState)
  self.stateParameters.animations.default = 'swim'
  self.stateParameters.interactionCollisions = true
  self.player:interruptItems()
  self.isSubmerged = false
  self.isDrowning = false

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
  self.isDrowning = false
end

function PlayerSwimEnvironmentState:update()
  if not self.isDrowning then
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
end


return PlayerSwimEnvironmentState