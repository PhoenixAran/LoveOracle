local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local Singletons = require 'engine.singletons'
local Tween = require 'lib.tween'
local rect = require 'engine.utils.rectangle'

local RespawnState = {
  DeathAnimation = 0,
  ViewPanning = 1,
  Delay = 2
}

---@class PlayerRespawnDeathState : PlayerState
---@field waitForAnimation boolean
---@field respawnState integer
---@field camera any
---@field cameraSubject any
---@field cameraTween any
---@field originalCameraFollowStyle string
---@field originalCameraFollowLerp number
local PlayerRespawnDeathState = Class { __includes = PlayerState,
  ---@param self PlayerRespawnDeathState
  init = function(self)
    PlayerState.init(self)

    self.waitForAnimation = true
    self.respawnState = RespawnState.DeathAnimation
    self.stateParameters.canStrafe = true
    self.stateParameters.canControlOnGround = false
    self.stateParameters.canControlInAir = false

    self.camera = nil
    self.cameraSubject = { }
    self.originalCameraFollowStyle = nil
    self.originalCameraFollowLerp = nil
  end
}

function PlayerRespawnDeathState:getType()
  return 'player_respawn_death_state'
end

function PlayerRespawnDeathState:endDeathAnimationState()
  self.player:respawn()
end

function PlayerRespawnDeathState:startViewPanningState()
  self.respawnState = RespawnState.ViewPanning
  self.waitForAnimation = false
  if rect.containsPoint(self.camera.x, self.camera.y, self.camera.x, self.camera.y, self.player:getPosition()) then
    self:startDelayState()
  else
    self:startViewPanningState()
  end
end

function PlayerRespawnDeathState:endViewPanningState()

end

function PlayerRespawnDeathState:startDelayState()
  self.respawnState = RespawnState.Delay
end

function PlayerRespawnDeathState:endDelayState()

end

function PlayerRespawnDeathState:update(dt)
  if self.respawnState == RespawnState.DeathAnimation then
    if (not self.waitForAnimation) or self.player.sprite:isCompleted() then
      self:endDeathAnimationState()
    end
  elseif self.respawnState == RespawnState.ViewPanning then

    self:endViewPanningState()
  elseif self.respawnState == RespawnState.Delay then
    self:endDelayState()
  end
end

---@param previousState PlayerState
function PlayerRespawnDeathState:onBegin(previousState)
  self.respawnState = RespawnState.DeathAnimation
  self.stateParameters.canStrafe = true
  self.stateParameters.canControlOnGround = false
  self.stateParameters.canControlInAir = false
  self.player:setVisible(false)

  self.camera = Singletons.camera
  self.originalCameraFollowLerp = self.camera.follow_lerp_x
  self.originalCameraFollowStyle = self.camera.follow_style

  self.camera:setFollowStyle()
end



function PlayerRespawnDeathState:onEnd(newState)
  self.player = nil
  self.camera = nil
end

return PlayerRespawnDeathState
