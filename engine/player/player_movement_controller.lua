local Class = require 'lib.class'
local lume  = require('lib.lume')
local PlayerMotionType = require 'engine.player.player_motion_type'
local vector = require 'engine.math.vector'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local TileTypes = TileTypeFlags.enumMap
local Input = require('engine.singletons').input
local Physics = require 'engine.physics'
local Constants = require 'constants'

-- how many times to 'split the pie' when clamping joystick vector to certian radian values
local DIRECTION_SNAP = 40

---@class PlayerMovementController
---@field player Player
---@field movement Movement
---@field allowMovementControl boolean
---@field preStrokeSpeedScale number
---@field strokeSpeedScale number
---@field lastStrokeVectorX number
---@field lastStrokeVectorY number
---@field directionX number
---@field directionY number
---@field stroking boolean
---@field capeDeployed boolean
---@field holeTile Tile?
---@field doomedToFallInHole boolean
---@field holeDoomTimer number
---@field holeSlipVelocityX number
---@field holeSlipVelocityY number
---@field holeQuadrantX number
---@field holeQuadrantY number
---@field fallingInHole boolean
---@field moveNormalMode PlayerMotionType
---@field mode PlayerMotionType
local PlayerMovementController = Class {
  ---@param self PlayerMovementController
  ---@param player Player
  ---@param movement Movement
  init = function(self, player, movement)
    self.player = player
    self.movement = movement

    self.allowMovementControl = true
    self.strokeSpeedScale = 1.0
    self.directionX, self.directionY = 0, 0
    self.moving = false
    self.stroking = false
    self.lastStrokeVectorX = 0
    self.lastStrokeVectorY = 0
    self.capeDeployed = false

    self.holeTile = nil
    self.doomedToFallInHole = false
    self.holeDoomTimer = 0
    self.holeQuadrantX, self.holeQuadrantY = 0, 0
    self.holeSlipVelocityX, self.holeSlipVelocityY = 0, 0
    self.fallingInHole = false

    self.moveNormalMode = PlayerMotionType()
    self.mode = self.moveNormalMode
  end
}

function PlayerMovementController:isMoving()
  return self.moving
end

---@param mode PlayerMotionType
function PlayerMovementController:setMode(mode)
  if self.mode ~= mode then
    self.mode = mode
    self.movement:setSpeed(mode.speed)
    self.movement:setAcceleration(mode.acceleration)
    self.movement:setDeceleration(mode.deceleration)
    self.movement:setMinSpeed(mode.minSpeed)
    self.movement:setSlippery(mode.slippery)
  end
end


function PlayerMovementController:jump()
  if self.player:isOnGround() 
     and self.player:getStateParameters().canJump 
     and not self.player.groundObserver.inHole 
     and self.player.skills.jumpSkill > 0 then
    if self.player:getStateParameters().canControlOnGround then
      local x, y = self:pollMovementControls(true)
      if self:isMoving() then
        self.player:setVector(x, y)
        -- man handle the speed
        self.movement:setSpeed(self.movement:getSpeed() * self.player:getStateParameters().movementSpeedScale * self.strokeSpeedScale)
      end
    end
    -- jump!
    self.capeDeployed = false
    self.movement.gravity = Constants.PLAYER_JUMP_GRAVITY
    self.movement:setZVelocity(Constants.PLAYER_JUMP_Z_VELOCITY)
    self.player:requestNaturalState()
    self.player:integrateStateParameters()
    if self.player:getWeaponState() ~= nil and self.player:getWeaponState():getType() == 'player_push_state' then
      -- end the push state so we can jump
      self.player:getWeaponState():endState()
      self.player:integrateStateParameters()
    end
    if self.player:getWeaponState() == nil then
      self.player.sprite:play('jump')
    end
    if self.player.onJump then
      self.player:onJump()
    end
  end
end

function PlayerMovementController:isDoomedToFallInHole()
  return self.fallingInHole and self.doomedToFallInHole
end

---@param allowMovementControl boolean
function PlayerMovementController:pollMovementControls(allowMovementControl)
  local x, y = 0, 0
  self.moving = false
  if allowMovementControl then
    x, y = Input:get('move')
    x, y = vector.snapDirectionByCount(x, y, DIRECTION_SNAP)
    self.directionX, self.directionY = x, y
    if x ~= 0 or y ~= 0 then
      self.moving = true
    end
  end
  return x, y
end

function PlayerMovementController:chooseAnimation()
  local player = self.player
  local sprite = self.player.sprite
  local stateParameters = self.player:getStateParameters()
  local animation = sprite:getCurrentAnimationKey()
  if player:isOnGround() and self.allowMovementControl and
     (animation == player:getPlayerAnimations().move or animation == 'idle' or animation == 'carry') then

    if self.moving then
      if not sprite:isPlaying() then
        sprite:play()
      end
    elseif animation ~= player:getPlayerAnimations().default then
      sprite:play(player:getPlayerAnimations().default)
    end
  end

  -- change to the default animation while in the air and not using weapon
  if player:isInAir() and self.allowMovementControl and player:getWeaponState() == nil and sprite:getCurrentAnimationKey() ~= 'jump' then
    sprite:play(player:getPlayerAnimations().move)
  end

  animation = sprite:getCurrentAnimationKey()

  -- move animation can be replaced by cap animation
  if animation == player:getPlayerAnimations().move and player:isInAir() and self.capeDeployed then
    sprite:play('cape')
  elseif player:isOnGround() and animation == 'cape' then
    sprite:play(player:getPlayerAnimations().default)
  end
end

function PlayerMovementController:updateStroking()
  if self.player:isSwimming() then
    -- remember the speedscale before going into the water
    if self.preStrokeSpeedScale == nil then
      self.preStrokeSpeedScale = self.player.movement:getSpeedScale()
    end
    -- slow down movement over time from strokes
    if self.strokeSpeedScale > 1.0 then
      self.strokeSpeedScale = self.strokeSpeedScale - 0.025
    end

    -- auto accelerate during the beginning of a stroke
    self.stroking = self.strokeSpeedScale > 1.3

    if self.stroking then
      -- player still needs to move if they stroke even if they dont have a direction held down
      local x, y = self.player:getVector()
      if x == 0 and y == 0 then
        self.player:setVector(self.lastStrokeVectorX, self.lastStrokeVectorY)
      else
        self.lastStrokeVectorX, self.lastStrokeVectorY = x, y
      end
    end
    self.player:setSpeedScale(self.strokeSpeedScale)
  else
    self.strokeSpeedScale = 1.0
    self.stroking = false
    self.lastStrokeVectorX, self.lastStrokeVectorY = 0, 0
  end

  -- set the speedscale back to what it was before swimming
  if not self.player:isSwimming() and self.preStrokeSpeedScale ~= nil then
    self.player:setSpeedScale(self.preStrokeSpeedScale)
    self.preStrokeSpeedScale = nil
  end
end

--- if we can stroke in the water
---@return boolean
function PlayerMovementController:canStroke()
  return self.player:isSwimming() and self.strokeSpeedScale <= 1.4 and self.allowMovementControl
end

function PlayerMovementController:stroke()
  self.strokeSpeedScale = 2.0
  self.player:setSpeedScale(self.strokeSpeedScale)
  -- TODO play audio
  self.stroking = true

  local x, y = self.player:getVector()
  if x == 0 and y == 0 then
    self.lastStrokeVectorX, self.lastStrokeVectorY = Direction4.getVector(self.player:getAnimationDirection4())
  else
    self.lastStrokeVectorX = x
    self.lastStrokeVectorY = y
  end
end

function PlayerMovementController:stayInsideHole()
  local px, py = self.player:getPosition()
  local vx, vy = self.player:getVector()
  local tx, ty, tw, th = self.holeTile:getBounds()
  if px < tx then
    self.player:setPosition(tx, py) -- Set to the left boundary
    self.player:setVector(0, vy)
  elseif px > tx + tw then
    self.player:setPosition(tx + tw, py) -- Set to the right boundary
    self.player:setVector(0, vy)
  end

  vx, vy = self.player:getVector() 
  px, py = self.player:getPosition()

  if py < ty then
    self.player:setPosition(px, ty) -- Set to the top boundary
    self.player:setVector(vx, 0)
  elseif py > ty + th then
    self.player:setPosition(px, ty + th) -- Set to the bottom boundary
    self.player:setVector(vx, 0)
  end
  Physics:update(self.player, self.player.x, self.player.y)
end

---@return Tile?
function PlayerMovementController:getCurrentHoleTile()
  local holeTile
  for k, v in ipairs(self.player.groundObserver:getVisitedTiles()) do
    if v:getTileType() == TileTypes.Hole then
      holeTile = v
      break
    end
  end
  return holeTile
end

function PlayerMovementController:updateFallingInHole()
  if self.fallingInHole then
    self.holeDoomTimer = self.holeDoomTimer - 1

    -- after delay, disable player motion
    if self.holeDoomTimer < 0 then
      self.player:setVector(0, 0)
    end

    if not self.player.groundObserver.inHole then
      -- stop falling in hole
      self.fallingInHole = false
      self.doomedToFallInHole = false
      self.holeTile = nil
      return
    elseif self.doomedToFallInHole then
      self:stayInsideHole()
    else
      -- check if the player has changed quadrants
      -- which dooms them to fall in the hole
      local newHoleTile = self:getCurrentHoleTile()
      local newQuadrantX, newQuadrantY = vector.div(8, self.player:getPosition())
      newQuadrantX = math.floor(newQuadrantX)
      newQuadrantY = math.floor(newQuadrantY)
      if newQuadrantX ~= self.holeQuadrantX or newQuadrantY ~= self.holeQuadrantY then
        self.doomedToFallInHole = true
        self.holeTile = newHoleTile
      end
    end

    -- move towards the hole's center
    local px, py = self.player:getPosition()
    local tx, ty = self.holeTile:getPosition()

    local pullMagnitude = Constants.PLAYER_HOLE_PULL_MAGNITUDE

    -- increase pull magnitude if player is trying to move away from hole
    local pdx, pdy = vector.normalize(self.player:getVector())
    local diffX, diffY = vector.sub(tx, ty, px, py)
    local normDiffX, normDiffY = vector.normalize(diffX, diffY)
    local dotProduct = vector.dot(pdx, pdy, normDiffX, normDiffY)
    -- check if the dot product is between PI/2 AND 3PI/2
    if 0 > dotProduct then
      pullMagnitude = pullMagnitude * 2
    end

    local pullX, pullY = vector.mul(pullMagnitude * love.time.dt, normDiffX, normDiffY)

    -- pull player towards hole
    self.player:setPosition(px + pullX, py + pullY)

    -- fall in hole when too close to center
    if vector.dist(tx, ty, self.player:getPosition()) <= Constants.PLAYER_DISTANCE_TRIGGER_HOLE_FALL then
      self.player:setPosition(tx, ty)
      self.player.sprite:play('fall')
      self.player:startRespawnControlState(false)
      self.holeTile = nil
      self.fallingInHole = false
      self.doomedToFallInHole = false
    end
  elseif self.player.groundObserver.inHole then
    -- check if we are in a respawn death state. This prevents infinite falling loop
    local currentControlState = self.player.controlStateMachine:getCurrentState()
    if not (currentControlState ~= nil and currentControlState:getType() == 'player_respawn_death_state') then
      -- start falling in a hole
      self.holeTile = self:getCurrentHoleTile()
      self.holeQuadrantX, self.holeQuadrantY = vector.div(8, self.player:getPosition())
      self.holeQuadrantX = math.floor(self.holeQuadrantX)
      self.holeQuadrantY = math.floor(self.holeQuadrantY)
      self.doomedToFallInHole = false
      self.fallingInHole = true
      self.holeDoomTimer = Constants.PLAYER_HOLE_DOOM_TIMER
    end
  end
end

function PlayerMovementController:updateMoveMode()
  if self.player.environmentStateMachine:isActive() then
    local currentEnvironmentState = self.player.environmentStateMachine:getCurrentState()
---@diagnostic disable-next-line: need-check-nil, undefined-field
    self:setMode(currentEnvironmentState.motionSettings)
  else
    self:setMode(self.moveNormalMode)
  end
end

function PlayerMovementController:updateMoveControls()
  if self.player:isInAir() then
    if not self.player:getStateParameters().canControlInAir then
      self.allowMovementControl = false
    elseif self.player.movement:getZVelocity() >= .1 then
      self.allowMovementControl = false
    else
      self.allowMovementControl = true
    end
  else
    self.allowMovementControl = not self.player:inHitstun() and not self.player:inKnockback()
                                and self.player:getStateParameters().canControlOnGround
  end
  local inputX, inputY = self:pollMovementControls(self.allowMovementControl)
  local canUpdateDirection = false
  if self.player:getStateParameters().alwaysFaceUp then
    canUpdateDirection = inputX == 0 and inputY == -1
  elseif self.player:getStateParameters().alwaysFaceLeft then
    canUpdateDirection = inputX == -1 and inputY == 0
  elseif self.player:getStateParameters().alwaysFaceRight then
    canUpdateDirection = inputX == 1 and inputY == 0
  elseif self.player:getStateParameters().alwaysFaceDown then
    canUpdateDirection = inputX == 0 and inputY == 1
  else
    canUpdateDirection = not self.player:getStateParameters().canStrafe
  end

  if canUpdateDirection and self.allowMovementControl and self.moving then
    self.player:matchAnimationDirection(inputX, inputY)
  end
  self.player:setVector(inputX, inputY)
  self:chooseAnimation()
end

function PlayerMovementController:update()
  self:updateMoveMode()
  self:updateMoveControls()
  self:updateFallingInHole()
  self:updateStroking()
  if self.allowMovementControl then
    if self.player:getStateParameters().alwaysFaceUp then
      if self.player.animationDirection4 ~= Direction4.up then
        self.player:setAnimationDirection4(Direction4.up)
      end
    elseif self.player:getStateParameters().alwaysFaceLeft then
      if self.player.animationDirection4 ~= Direction4.left then
        self.player:setAnimationDirection4(Direction4.left)
      end
    elseif self.player:getStateParameters().alwaysFaceRight  then
      if self.player.animationDirection4 ~= Direction4.right then
        self.player:setAnimationDirection4(Direction4.right)
      end
    elseif self.player:getStateParameters().alwaysFaceDown then
      if self.player.animationDirection4 ~= Direction4.down then
        self.player:setAnimationDirection4(Direction4.down)
      end
    end
  end
end

return PlayerMovementController