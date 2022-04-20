local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local Collider = require 'engine.components.collider'
local SpriteBank = require 'engine.utils.sprite_bank'
local Entity = require 'engine.entities.entity'
local Combat = require 'engine.components.combat'
local Health = require 'engine.components.health'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'
local SpriteFlasher = require 'engine.components.sprite_flasher'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'

local Physics = require 'engine.physics'
local TablePool = require 'engine.utils.table_pool'
local DamageInfo = require 'engine.entities.damage_info'

local MapEntity = Class { __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)

    if args.direction == nil then
      args.direction = Direction4.none
    else
      if type(args.direction) == 'string' then
        args.direction = Direction4[args.direction] or Direction4.none
      else
        args.direction = args.direction
      end
    end

    -- signals
    self:signal('entityDestroyed')
    self:signal('entityCreated')
    self:signal('entityHit')
    self:signal('entityBumped')
    self:signal('entityImmobolized')
    self:signal('entityMarkedDead')

    self.health = Health(self)
    self.movement = Movement(self)
    self.groundObserver = GroundObserver(self)
    self.combat = Combat(self)
    self.effectSprite = SpriteBank.build('entity_effects', self)
    self.spriteFlasher = SpriteFlasher(self)
    self.sprite = nil   -- declare this yourself

    -- this collision box will NOT actually exist in the Physics system
    -- if this is not null, it will only be used to collide with room edges if you want the room edge collider
    -- to be different
    self.roomEdgeCollisionBox = nil

    -- table to store collisions that occur when MapEntity:move() is called
    self.moveCollisions = { }
    -- tile types this entity reports collisions with
    self.collisionTiles = { }

    -- declarations
    self.deathMarked = false
    self.persistant = false
    self.syncDirectionWithAnimation = true  -- if this is set to true, self.sprite will be assumed to be an AnimatedSpriteRenderer
    self.animationDirection4 = args.direction -- will be used as substrip key if syncDirectionWithAnimation is true
    -- shadow, ripple, and grass effects
    -- TODO finish ripple and grass effects
    self.shadowVisible = true
    --self.shadowOffsetX, self.shadowOffsetY = 0, 0
    self.rippleVisible = false
    --self.rippleOffsetX, self.rippleOffsetY = 0, 0
    self.grassVisible = false
    --self.grassOffsetX, self.grassOffsetY = 0, 0
  end
}

function MapEntity:getType()
  return 'map_entity'
end

function MapEntity:getCollisionTag()
  return 'map_entity'
end

function MapEntity:onTransformChanged()
  if self.roomEdgeCollisionBox then
    self.roomEdgeCollisionBox:onTransformChanged()
  end
end

function MapEntity:release()
  lume.clear(self.moveCollisions)
  Entity.release(self)
end

function MapEntity:isPersistant()
  return self.persistant
end

function MapEntity:setCollisionTile(tileType)
  if type(tileType) == 'table' then
    for _, val in ipairs(tileType) do
      self.collisionTiles[val] = true
    end
  else
    self.collisionTiles[tileType] = true
  end
end

function MapEntity:unsetCollisionTile(tileType)
  if type(tileType) == 'table' then
    for _, val in ipairs(tileType) do
      self.collisionTiles[val] = nil
    end
  else
    self.collisionTiles[tileType] = nil
  end
end

-- animation
function MapEntity:setSyncDirectionWithAnimation(value)
  self.syncDirectionWithAnimation = true
end

function MapEntity:doesSyncDirectionWithAnimation()
  return self.syncDirectionWithAnimation
end

function MapEntity:setAnimationDirection4(value)
  self.animationDirection4 = value
  if self:doesSyncDirectionWithAnimation() and self.sprite ~= nil then
    assert(self.sprite:getType() == 'animated_sprite_renderer')
    if self.sprite:getSubstripKey() ~= value then
      self.sprite:setSubstripKey(value)
    end
  end
end

function MapEntity:getAnimationDirection4()
  return self.animationDirection4
end

function MapEntity:pollDeath()
  if self.deathMarked and not (self:inHitstun() or self:inKnockback()) then
    self:die()
  end
end

function MapEntity:die()
  self:release()
  self:emit('entityDestroyed')
end

-- health component pass throughs
function MapEntity:getMaxHealth()
  return self.health:getMaxHealth()
end

function MapEntity:getHealth()
  return self.health:getHealth()
end

function MapEntity:setHealth(value)
  self.health:setHealth(value)
end

function MapEntity:getArmor()
  return self.health:getArmor()
end

function MapEntity:setArmor(value)
  self.health:setArmor(value)
end

-- movement component pass throughs
function MapEntity:getVector()
  return self.movement:getVector()
end

function MapEntity:setVector(x, y)
  return self.movement:setVector(x, y)
end

function MapEntity:getDirection4()
  return self.movement:getDirection4()
end

function MapEntity:getDirection8()
  return self.movement:getDirection8()
end

function MapEntity:setVectorAwayFrom(x, y)
  local mx, my = self.movement:getVector()
  return self.movement:setVector(vector.sub(mx, my, x, y))
end

function MapEntity:getLinearVelocity(x, y)
  return self.movement:getLinearVelocity(x, y)
end

function MapEntity:getSpeed()
  return self.movement:getSpeed()
end

function MapEntity:setSpeed(value)
  self.movement:setSpeed(value)
end

function MapEntity:isInAir()
  if self.movement and self.movement:isEnabled() then
    return self.movement:isInAir()
  end
  return self:getZPosition() > 0
end

function MapEntity:isOnGround()
  return not self:isInAir()
end

function MapEntity:move(dt)
  lume.clear(self.moveCollisions)
  local posX, posY = self:getPosition()
  local velX, velY = self.movement:getLinearVelocity(dt)
  local kx, ky = self:getKnockbackVelocity(dt)
  velX, velY = vector.add(velX, velY, kx, ky)
  local bx = self.x + velX
  local by = self.y + velY
  local bw = self.w
  local bh = self.h
  local neighbors = Physics.boxcastBroadphase(self, bx, by, bw, bh)
  for i, neighbor in ipairs(neighbors) do
    if self:reportsCollisionsWith(neighbor) then
      local shouldCarryOutCollision = true
      if neighbor:isTile() then
        shouldCarryOutCollision = self.collisionTiles[neighbor:getTileType()]
      end
      if shouldCarryOutCollision then
        local collided, mtvX, mtvY, normX, normY = self:boxCast(neighbor, velX, velY)
        if collided then
          -- hit, back off our motion
          velX, velY = vector.sub(velX, velY, mtvX, mtvY)
          -- add other box to moveCollisions table
          lume.push(self.moveCollisions, neighbor)
        end
      end
    end
  end
  TablePool.free(neighbors)
  if self.roomEdgeCollisionBox then
    bx = self.roomEdgeCollisionBox.x + velX
    by = self.roomEdgeCollisionBox.y + velY
    bw = self.roomEdgeCollisionBox.w
    bh = self.roomEdgeCollisionBox.h
    neighbors = Physics.boxcastBroadphase(self.roomEdgeCollisionBox, bx, by, bw, bh)
    for i, neighbor in ipairs(neighbors) do
      if self.roomEdgeCollisionBox:reportsCollisionsWith(neighbor) then
        local collided, mtvX, mtvY, normX, normY = self.roomEdgeCollisionBox:boxCast(neighbor, velX, velY)
        if collided then
          -- hit from roomEdge, back off from motion
          velX, velY = vector.sub(velX, velY, mtvX, mtvY)
          -- add to moveCollisions table if it is not present
          local shouldAddToMoveCollisions = true
          for _, other in ipairs(self.moveCollisions) do
            if other == neighbor or self == neighbor then
              shouldAddToMoveCollisions = false
              break
            end
          end
          if shouldAddToMoveCollisions then
            lume.push(self.moveCollisions, neighbor)
          end
        end
      end
    end
    TablePool.free(neighbors)
  end
  self:setPosition(posX + velX, posY + velY)
  Physics.update(self)
end

-- combat component pass throughs
function MapEntity:isIntangible()
  return self.combat:isIntangible()
end

function MapEntity:inHitstun()
  return self.combat:inHitstun()
end

function MapEntity:inKnockback()
  return self.combat:inKnockback()
end

function MapEntity:setIntangibility(value)
  self.combat:setIntangibility(value)
end

function MapEntity:setHitstun(value)
  self.combat:setHitstun(value)
end

function MapEntity:setKnockback(value)
  self.combat:setKnockback(value)
end

function MapEntity:resetCombatVariables()
  self.combat:resetCombatVariables()
end

function MapEntity:getKnockbackVector(x, y)
  return self.combat:getKnockbackVector()
end

function MapEntity:setKnockbackVector(x, y)
  self.combat:setKnockbackVector(x, y)
end

function MapEntity:setKnockbackSpeed(speed)
  self.combat:setKnockbackSpeed(speed)
end

function MapEntity:getKnockbackSpeed()
  return self.combat:getKnockbackSpeed()
end

function MapEntity:getKnockbackVelocity(dt)
  return self.combat:getKnockbackVelocity(dt)
end

function MapEntity:hurt(damageInfo)
  if type(damageInfo) == 'number' then
    local damage = damageInfo
    damageInfo = DamageInfo()
    damageInfo.damage = damage
  end
  self:resetCombatVariables()
  if damageInfo:applyHitstun() then
    self:setHitstun(damageInfo.hitstunTime)
    self:setIntangibility(damageInfo.hitstunTime)
    self:flashSprite(damageInfo.hitstunTime)
  end
  if damageInfo:applyKnockback() then
    self:setKnockback(damageInfo.knockbackTime)
    self:setKnockbackSpeed(damageInfo.knockbackSpeed)
    local ex, ey = self:getPosition()
    self:setKnockbackVector(vector.sub(ex, ey,damageInfo.sourceX, damageInfo.sourceY))
  end

  self.health:takeDamage(damageInfo.damage)
  if self.onHurt then
    self:onHurt(damageInfo)
  end
  self:signal('entityHit')
end

function MapEntity:bump(sourcePositionX, sourcePositionY, duration, speed)
  -- TODO bump entity
  if self.onBump then
    self:onBump(sourcePositionX, sourcePositionY, duration, speed)
  end
  self:signal('entityBumped')
end

-- sprite flash
function MapEntity:flashSprite(duration)
  self.spriteFlasher:flash(duration)
end

function MapEntity:stopSpriteFlash()
  self.spriteFlasher:stop()
end

-- entity effect sprite update
function MapEntity:updateEntityEffectSprite(dt)
  if self.shadowVisible and self:isInAir() then
    if self.effectSprite:getCurrentAnimationKey() ~= 'shadow' or not self.effectSprite:isVisible() then
      self.effectSprite:play('shadow')
      self.effectSprite:setVisible(true)
      self.effectSprite.alpha = .5
    end
  elseif self.effectSprite:isVisible() then
    self.effectSprite:stop()
    self.effectSprite:setVisible(false)
  end
  self.effectSprite:update(dt)
end

-- signal callbacks
function MapEntity:_onHealthDepleted()
  self.deathMarked = true
end

return MapEntity
