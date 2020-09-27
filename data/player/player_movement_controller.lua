local Class = require 'lib.class'
local PlayerMotionType = require 'data.player.player_motion_type'
local vector = require 'lib.vector'


-- handles more advance manipulation of the Movement component for the player
local PlayerMovementController = Class {
  init = function(self, player, movement)
    self.player = player
    self.movement = movement
    
    self.allowMovementControl = true
    self.strokeSpeedScale = 1.0
    self.moveAxesX, self.moveAxesY = false, false
    self.motionX, self.motionY = 0, 0
    self.isMoving = false
    self.mode = PlayerMotionType()
    --self.moveAngle = 'south'  -- not sure if I need this
    self.holeTile = nil
    self.holeDoomTimer = 0
    self.holeSlipVelocityX, self.holeSlipVelocityY = 0, 0
    self.fallingInHole = false
    
    self.moveNormalMode = PlayerMotionType()
    self.mode = self.moveNormalMode
  end
}

function PlayerMovementController:updateMoveMode()
  if self.player.environmentState ~= nil then
    self.mode = self.player.environentState.motionType
  else
    self.mode = self.moveNormalMode
  end
end

function PlayerMovementController:updateMoveControls()
  -- TODO
  -- check if player is allowed to move
end

function PlayerMovementController:update(dt)
  self:updateMoveMode()
end

