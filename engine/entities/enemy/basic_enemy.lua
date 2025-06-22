local Class = require 'lib.class'
local Enemy = require 'engine.entities.enemy'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Pool = require 'engine.utils.pool'
local Physics = require 'engine.physics'
local EffectFactory = require 'engine.entities.effect_factory'
local Singletons = require 'engine.singletons'
local Axis = require 'engine.enums.axis'
local Direction4 = require 'engine.enums.direction4'


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
local BasicEnemy = Class { __includes = Enemy,
  init = function(self, args)
    Enemy.init(self, args)
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
    self.avoidHazardTiles = args.avoidHazardTiles or true

    -- charging
    self.chargeType = args.chargeType or ChargeType.None
    self.chargeSpeed = args.chargeSpeed or 100
    self.chargeMinAlignment = args.chargeMinAlignment or 0.5
    self.chargeDurationMin = args.chargeDurationMin or 0
    self.chargeDurationMax = args.chargeDurationMax or 0
    self.chargeCooldownTimer = args.cooldownTimer or 0

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

    -- states
    self.isMoving = false
    self.moveTimer = lume.random(self.stopTimeMin, self.stopTimeMax)
    self.isChasingPlayer = false
    self.isPaused = false
    self.isShooting = false

    -- TODO color initialization
  end
}

function BasicEnemy:getType()
  return 'basic_enemy'
end

function BasicEnemy:shoot()
  error('not implemented')
end

function BasicEnemy:updateChargingState()
  error('not implemented')
end

function BasicEnemy:facePlayer()
  error('not implemented')
end

function BasicEnemy:updateMovingState()
  error('not implemented')
end

function BasicEnemy:updateStoppedState()
  error('not implemented')
end

---@param axis Axis
function BasicEnemy:startCharging(axis)

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
        self:setVector(vector.sub(px, py, self:getPosition()))
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
            self:startCharging(axis)
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

return BasicEnemy