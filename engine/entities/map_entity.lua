local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local SpriteBank = require 'engine.utils.sprite_bank'
local Entity = require 'engine.entities.entity'
local Combat = require 'engine.components.combat'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'
local SpriteFlasher = require 'engine.components.sprite_flasher'

local Physics = require 'engine.physics'
local TablePool = require 'engine.utils.table_pool'
local DamageInfo = require 'engine.entities.damage_info'

local MapEntity = Class { __includes = Entity,
  init = function(self, name, enabled, visible, rect, zRange)
    Entity.init(self, name, enabled, visible, rect, zRange)
    
    -- signals
    self:signal('entityDestroyed')
    self:signal('entityCreated')
    self:signal('entityHit')
    self:signal('entityBumped')
    self:signal('entityImmobolized')
    self:signal('entityMarkedDead')
    
    
    self.movement = Movement(self)    
    self.groundObserver = GroundObserver(self)
    self.combat = Combat(self)
    self.effectSprite = SpriteBank.build('entity_effects', self)
    self.spriteFlasher = SpriteFlasher(self)
    self.sprite = nil   -- declare this yourself
    
    -- declarations
    self.persistant = false
    self.syncDirectionWithAnimation = true  -- if this is set to true, self.sprite will be assumed to be an AnimatedSpriteRenderer
    self.animationDirection = nil -- will be used as substrip key if syncDirectionWithAnimation is true
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

function MapEntity:isPersistant()
  return self.persistant
end

-- animation
function MapEntity:setSyncDirectionWithAnimation(value)
  self.syncDirectionWithAnimation = true
end

function MapEntity:doesSyncDirectionWithAnimation()
  return self.syncDirectionWithAnimation
end

function MapEntity:setAnimationDirection(value)
  self.animationDirection = value
  if self:doesSyncDirectionWithAnimation() and self.sprite ~= nil then
    assert(self.sprite:getType() == 'animated_sprite_renderer')
    if self.sprite:getSubstripKey() ~= value then
      self.sprite:setSubstripKey(value)
    end
  end
end

function MapEntity:getAnimationDirection()
  return self.animationDirection
end

-- movement component pass throughs
function MapEntity:getVector()
  return self.movement:getVector()
end

function MapEntity:setVector(x, y)
  return self.movement:setVector(x, y)
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
  self.movement:setSpeed(speed)
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
  local posX, posY = self:getPosition()
  local velX, velY = self.movement:getLinearVelocity(dt)
  velX, velY = vector.add(velX, velY, self:getKnockbackVelocity(dt))
  local bx = self.x + velX
  local by = self.y + velY
  local bw = self.w
  local bh = self.h
  local neighbors = Physics.boxcastBroadphase(self, bx, by, bw, bh)
  for i, neighbor in ipairs(neighbors) do
    if self:reportsCollisionsWith(neighbor) then
      local collided, mtvX, mtvY, normX, normY = self:boxCast(neighbor, velX, velY)
      if collided then
        -- hit, back off our motion
        velX, velY = vector.sub(velX, velY, mtvX, mtvY)
      end
    end
  end
  self:setPosition(posX + velX, posY + velY)
  TablePool.free(neighbors)
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

function MapEntity:getKnockbackDirection(x, y)
  return self.combat:getKnockbackDirection()
end

function MapEntity:setKnockbackDirection(x, y)
  self.combat:setKnockbackDirection(x, y)
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
    self:setHitstun(damageInfo.hitstun)
  end
  if damageInfo:applyKnockback() then
    self:setKnockback(damageInfo.knockback)
    self:setSpeed(damageInfo.knockbackSpeed)
    self:setVectorAwayFrom(damageInfo.sourceX, damageInfo.sourceY)
  end

  -- TODO take damage
  self:signal('entityHit')
end

function MapEntity:bump(sourcePositionX, sourcePositionY, duration, speed)
  -- TODO bump entity
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

return MapEntity