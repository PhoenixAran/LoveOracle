local Class = require 'lib.class'
local Enemy = require 'engine.entities.enemy.enemy'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Pool = require 'engine.utils.pool'
local Physics = require 'engine.physics'
local EffectFactory = require 'engine.entities.effect_factory'
local Singletons = require 'engine.singletons'
local Axis = require 'engine.enums.axis'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TablePool = require 'engine.utils.table_pool'


-- require states so they register themslves in the pool
require 'engine.entities.enemy.states'

local ChargeType = {
  None = 'none',
  Charge = 'charge',
  ChargeUntilCollision = 'charge_until_collision',
  ChargeUntilCollisionWithEnemy = 'charge_until_collision_with_enemy',
}

local AimType = {
  Forward = 'forward',
  FacePlayer = 'face_player', 
  FaceRandom = 'face_random',
  SeekPlayer = 'seek_player'
}

local ShootType = {
  None = 'none',
  OnStop = 'on_stop', 
  WhileMoving = 'while_moving'
}

local RandomDirectionChoiceType = {
  angle = 0,
  dir4 = 1,
  dir8 = 2
}

--- Class with more built in behaviour for enemies. 
--- Most enemies should inherit from this class.
---@class BasicEnemy : Enemy
---@field fallInHoleEffectColor string
---@field stopTimeMin number
---@field stopTimeMax number
---@field moveTimeMin number
---@field moveTimeMax number
---@field facePlayerOdds integer
---@field numMoveAngles integer
---@field avoidHazardTiles boolean
---@field chargeType string
---@field chargeSpeed number
---@field chargeAcceleration number
---@field chargeMinAlignment integer
---@field chargeDurationMin integer
---@field chargeDurationMax integer
---@field chargeCooldown number
---@field chargeCooldownTimer integer
---@field chaseSpeed number
---@field chaseSpeedPauseDuration integer
---@field shootType string
---@field aimType string
---@field projectileTypeClass any?
---@field shootSpeed number
---@field shootPauseDuration integer
---@field shootSound any?
---@field isMoving boolean
---@field moveTimer integer
---@field isChasingPlayer boolean
---@field isPaused boolean
---@field pauseTimer integer
---@field isShooting boolean
---@field isCharging boolean
---@field moveDirectionX number
---@field moveDirectionY number
---@field moveSpeed number
---@field animationMove string
---@field randomDirectionChoiceType integer
---@field projectileShootOdds integer
---@field changeDirectionOnCollision boolean
local BasicEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)

    self.randomDirectionChoiceType = args.randomDirectionChoiceType or RandomDirectionChoiceType.dir4

    -- environment configuration
    self.canFallInHole = args.canFallInHole or true
    self.canSwimInLava = args.canSwimInLava or false
    self.canSwimInWater = args.canSwimInWater or false
    self.fallInHoleEffectColor = args.fallInHoleEffectColor or 'blue'

    -- movement
    self.stopTimeMin = args.stopTimeMin or 30
    self.stopTimeMax = args.stopTimeMax or 60
    self.moveTimeMin = args.moveTimeMin or 30
    self.moveTimeMax = args.moveTimeMax or 50
    self.moveSpeed = args.moveSpeed or 50
    self.avoidHazardTiles = args.avoidHazardTiles or true
    self.animationMove = args.animationMove or 'move'
    self.changeDirectionOnCollision = args.changeDirectionOnCollision or true
    self.moveDirectionX = args.moveDirectionX or 0
    self.moveDirectionY = args.moveDirectionY or 0

    -- charging
    self.chargeType = args.chargeType or ChargeType.None
    self.chargeSpeed = args.chargeSpeed or 100
    self.chargeMinAlignment = args.chargeMinAlignment or 0.5
    self.chargeDurationMin = args.chargeDurationMin or 0
    self.chargeDurationMax = args.chargeDurationMax or 0
    self.chargeCooldownTimer = args.chargeCooldownTimer or 0

    -- chasing
    self.chaseSpeed = args.chaseSpeed or 100
    self.chasePauseDuration = args.chasePauseDuration or 30

    -- projectile
    self.shootType = args.shootType or ShootType.None
    self.aimType = args.aimType or AimType.FacePlayer
    self.projectileTypeClass = args.projectileTypeClass or nil
    self.shootSpeed = args.shootSpeed or 50
    self.shootPauseDuration = args.shootPauseDuration or 30
    self.shootSound = args.shootSound or nil  -- TODO
    self.projectileShootOdds = args.projectileShootOdds or 3  -- shoot every 1/3 times

    -- states
    self.isMoving = false
    self.moveTimer = lume.random(self.stopTimeMin, self.stopTimeMax)
    self.isChasingPlayer = false
    self.isPaused = false
    self.isShooting = false


    self:faceRandomDirection()
  end
}

function BasicEnemy:getType()
  return 'basic_enemy'
end

function BasicEnemy:changeDirection()
  if self.facePlayerOdds > 0 and math.floor(lume.random(0, self.facePlayerOdds)) == 0 then
    local player = Singletons.gameControl:getPlayer()
    local lookX, lookY = 0, 0
    if player then
      local px, py = player:getPosition()
      lookX, lookY = vector.sub(px, py, self:getPosition())
      lookX, lookY = vector.normalize(lookX, lookY)
      if self:canMoveInDirection(lookX, lookY) then
        self.moveDirectionX, self.moveDirectionY = lookX, lookY
        self:setVector(self.moveDirectionX, self.moveDirectionY)
        return
      end
    end
  end

  -- create a list of obstruction-free move angles
  -- TODO use numMoveAngles
  local possibleDirectionAngles = TablePool.obtain()
  for dir4 = 1, Direction4.count() - 1 do
    local testX, testY = Direction4.getVector(dir4)
    if self:canMoveInDirection(testX, testY) then
      lume.push(possibleDirectionAngles, dir4)
    end
  end

  if lume.count(possibleDirectionAngles) == 0 then
    -- No collision-free angles, so face a new random angle
    self.moveDirectionX, self.moveDirectionY = Direction4.getVector(math.random(1, 4))
  else
    self.moveDirectionX, self.moveDirectionY = Direction4.getVector(lume.randomchoice(possibleDirectionAngles))
  end

  self:setVector(self.moveDirectionX, self.moveDirectionY)

  TablePool.free(possibleDirectionAngles)
end

function BasicEnemy:faceRandomDirection()
  if self.randomDirectionChoiceType == RandomDirectionChoiceType.angle then
    local angle = lume.random(0, math.pi * 2)
    self.moveDirectionX, self.moveDirectionY = vector.fromAngle(angle)
  elseif self.randomDirectionChoiceType == RandomDirectionChoiceType.dir4 then
    local dir4 = math.floor(lume.random(1, Direction4.count()))
    self.moveDirectionX, self.moveDirectionY = Direction4.getVector(dir4)
  elseif self.randomDirectionChoiceType == RandomDirectionChoiceType.dir8 then
    local dir8 = math.floor(lume.random(1, Direction8.count()))
    self.moveDirectionX, self.moveDirectionY = Direction8.getVector(dir8)
  end
  self:setVector(self.moveDirectionX, self.moveDirectionY)
end

function BasicEnemy:startMoving()
  self.isMoving = true
  self:setSpeed(self.moveSpeed)
  self.moveTimer = math.floor(lume.random(self.moveTimeMin, self.moveTimeMax))

  self:changeDirection()
  self:setVector(self.moveDirectionX, self.moveDirectionY)

  if self.sprite then
    if not self.sprite:isPlaying() or self.sprite:getCurrentAnimationKey() ~= self.animationMove then
      print('playing ' .. self.animationMove)
      self.sprite:play(self.animationMove)
    end
  end
end

function BasicEnemy:stopMoving()
  self.moveTimer = math.floor(lume.random(self.stopTimeMin, self.stopTimeMax))
  self.isMoving = false
  self:setSpeed(0)

  -- shoot
  if self.shootType == ShootType.OnStop and self.projectileTypeClass ~= nil
            and math.floor(lume.random(self.projectileShootOdds)) == 0 then
    self:startShooting()
  end
end

function BasicEnemy:startShooting()
  self.pauseTimer = self.shootPauseDuration

  if self.aimType == AimType.FacePlayer then
    self:facePlayer()
  elseif self.aimType == AimType.FaceRandom then
    self:faceRandomDirection()
  end

  if self.pauseTimer == 0 then
    self:shoot()
  else
    self.isShooting = true
    self.isMoving = false
  end
end

-- TODO implmement this when i finish the projectile entity class
function BasicEnemy:shoot()
  if self.shootSound then
    -- TODO play sound
  end
  
  -- construct the projectile
  -- TODO

  -- TODO spawn the projectile

  error('not implemented')
end

--- Pauses the enemy for a given duration.
---@param duration integer
function BasicEnemy:pause(duration)
  self.pauseTimer = duration
  self.isPaused = true
end

function BasicEnemy:startCharging()
  self.moveDirectionX, self.moveDirectionY = Direction4.getVector(math.floor(lume.random(1, Direction4.count())))
  self.isCharging = true
  self.chargeCooldownTimer = self.chargeCooldown

  if self.chargeType == ChargeType.ChargeForDuration then
    self.moveTimer = math.floor(lume.random(self.chargeDurationMin, self.chargeDurationMax))
  end
end

function BasicEnemy:stopCharging()
  self.isCharging = false
  self:startMoving()
end

function BasicEnemy:updateChargingState()
  self:setSpeed(math.min(self.chargeSpeed, self.moveSpeed + self.chargeAcceleration))

  local tx, ty, collisions = self:testMove()

  if self.avoidHazardTiles then
    -- enemy will avoid going into hazard tiles
    -- TODO MAYBE: You can use Entity:getMeetingTiles() (and also implement an offset) if this doesnt adequetly check ahead enough
    for _, other in ipairs(collisions) do
      if other.isTile and other:isTile() and self:isHazardTile(other) then
        self:stopCharging()
        return
      end
    end
  end
  TablePool.free(collisions)

  if self.chargeType == ChargeType.ChargeForDuration then
    if self.moveTimer <= 0 then
      self:stopCharging()
      return
    end
  end

  if lume.any(self.moveCollisions) then
    self:stopCharging()
    return
  end

  self:move()
  self.moveTimer = self.moveTimer - 1
end

function BasicEnemy:updateMovingState()
  local tvx, tvy, collisions = self:move()

  -- stop moving after a duration
  if self.moveTimer <= 0 then
    self:stopMoving()
    return
  end

  -- collided into wall or other entity
  local collidedIntoWallOrEntity = false
  for _, other in ipairs(self.moveCollisions) do
    if other.isTile and other:isTile() then
      if other:isWall() and self.collidesWithWalls then
        collidedIntoWallOrEntity = true
        break
      end
    else
      collidedIntoWallOrEntity = true
      break
    end
  end

  -- change direction on collisions
  if self.changeDirectionOnCollision and collidedIntoWallOrEntity then
    self:changeDirection()
  elseif self.avoidHazardTiles then
    local tvx, tvy = self:getTestLinearVelocity()
    local items, len = self:getMeetingTiles(self.x + tvx, self.y + tvy)
    if len > 0 then
      self:changeDirection()
    end
    Physics.freeTable(items)
  end

  -- shoot while moving
  if self.shootType == ShootType.WhileMoving and self.projectileTypeClass ~= nil and math.floor(lume.random(self.projectileShootOdds)) == 0 then
    self:startShooting()
  end

  self.moveTimer = self.moveTimer - 1
end

function BasicEnemy:updateStoppedState()
  self:setVector(0, 0)

  -- start moving again after a duration
  if self.moveTimer <= 0 then
    self:startMoving()
  end

  self.moveTimer = self.moveTimer - 1
end

function BasicEnemy:facePlayer()
  local player = Singletons.gameControl:getPlayer()
  if player then
    local px, py = player:getPosition()
    self.moveDirectionX, self.moveDirectionY = vector.sub(px, py, self:getPosition())
    self.moveDirectionX, self.moveDirectionY = vector.normalize(self.moveDirectionX, self.moveDirectionY)
    self:setVector(self.moveDirectionX, self.moveDirectionY)
  end
end

function BasicEnemy:updateAi()
  if self:isOnGround() or self.movesInAir then
    if self.isPaused then
      if self.pauseTimer <= 0 then
        self.isPaused = false
      end
      self.pauseTimer = self.pauseTimer - 1
    elseif self.isShooting then
      if self.pauseTimer <= 0 then
        self:shoot()
      end
    elseif self.isCharging then
      self:updateChargingState()
    elseif self.isChasingPlayer then
      local player = Singletons.gameControl:getPlayer()
      if player then
        local px, py = player:getPosition()
        self:facePlayer()
        self.moveDirectionX, self.moveDirectionY = vector.sub(px, py, self:getPosition())
        self:setVector(self.moveDirectionX, self.moveDirectionY)
      end
    else
      -- check for charging
      if self.chargeCooldownTimer > 0 then
        self.chargeCooldownTimer = self.chargeCooldownTimer - 1
      elseif self.chargeType ~= ChargeType.None then
        local player = Singletons.gameControl:getPlayer()
        if player then
          local px, py = player:getPosition()
          local dir4 = Direction4.getDirection(vector.sub(px, py, self:getPosition()))
          local axis = nil
          if dir4 == Direction4.right or dir4 == Direction4.left then
            axis = Axis.horizontal
          elseif dir4 == Direction4.up or dir4 == Direction4.down then
            axis = Axis.vertical
          end
          if self:areBumpBoxCollisionAligned(player, axis) then
            self:startCharging()
          end
        end
      end

      if self.isMoving then
        self:updateMovingState()
      else
        self:updateStoppedState()
      end
    end
  end
end

BasicEnemy.ChargeType = ChargeType
BasicEnemy.AimType = AimType
BasicEnemy.ShootType = ShootType
BasicEnemy.RandomDirectionChoiceType = RandomDirectionChoiceType

return BasicEnemy