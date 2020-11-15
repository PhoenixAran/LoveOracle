local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local Combat = require 'engine.components.combat'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'
local vector = require 'lib.vector'

local GameEntity = Class { __includes = Entity,
  init = function(self, enabled, visible, rect)
    Entity.init(self, enabled, visible, rect)
    
    -- component declarations
    self.movement = Movement()    
    self.groundObserver = GroundObserver()
    self.combat = Combat()
    self.effectSprite = spriteBank.build('entity_effects')
    self.sprite = nil   -- declare this yourself
    
    -- declarations
    self.persistant = false
    self.syncDirectionWithAnimation = true  -- if this is set to true, self.sprite will be assumed to be an AnimatedSpriteRenderer
    self.animationDirection = nil -- will be used as substrip key if syncDirectionWithAnimation is true
    -- shadow, ripple, and grass effects
    -- TODO finish ripple and grass effecrts
    self.shadowVisible = true   
    --self.shadowOffsetX, self.shadowOffsetY = 0, 0
    self.rippleVisible = false
    --self.rippleOffsetX, self.rippleOffsetY = 0, 0
    self.grassVisible = false
    --self.grassOffsetX, self.grassOffsetY = 0, 0
    
    -- signals
    self:signal('entityDestroyed')
    self:signal('entityCreated')
    self:signal('entityHit')
    self:signal('entityBumped')
    self:signal('entityImmobolized')
    self:signal('entityMarkedDead')

    -- add components
    self:add(self.movement)
    self:add(self.groundObserver)
    self:add(self.combat)
    self:add(self.effectSprite)
  end 
}

function GameEntity:getType()
  return 'game_entity'
end

function GameEntity:getCollisionTag()
  return 'game_entity'
end

function GameEntity:isPersistant()
  return self.persistant
end

function GameEntity:setSyncDirectionWithAnimation(value)
  self.syncDirectionWithAnimation = true
end

function GameEntity:doesSyncDirectionWithAnimation()
  return self.syncDirectionWithAnimation
end

function GameEntity:setAnimationDirection(value)
  self.animationDirection = value
  if self:doesSyncDirectionWithAnimation() and self.sprite ~= nil then
    assert(self.sprite:getType() == 'animated_sprite_renderer')
    if self.sprite:getSubstripKey() ~= value then
      self.sprite:setSubstripKey(value)
    end
  end
end

function GameEntity:getAnimationDirection()
  return self.animationDirection
end

-- movement component pass throughs
function GameEntity:getVector()
  return self.movement:getVector()
end

function GameEntity:setVector(x, y)
  return self.movement:setVector(x, y)
end

function GameEntity:getLinearVelocity(x, y)
  return self.movement:getLinearVelocity(x, y)
end

function GameEntity:move(dt) 
  local posX, posY = self:getPosition()
  local velX, velY = self.movement:getLinearVelocity(dt)
  local bx = self.x + velX
  local by = self.y + velY
  local bw = self.w
  local bh = self.h
  local neighbors = physics.boxcastBroadphase(self, bx, by, bw, bh)
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
  physics.update(self)
end

function GameEntity:updateEntitySpriteEffects()
  if self.shadowVisible and self:isInAir() then
    if self.effectSprite:getCurrentAnimationKey() ~= 'shadow' or not self.effectSprite:isVisible() then
      self.effectSprite:play('shadow')
      self.effectSprite:setVisible(true)
    end
  elseif self.effectSprite:isVisible() then
    self.effectSprite:stop()
    self.effectSprite:setVisible(false)
  end
end

-- combat component pass throughs
function GameEntity:isIntangible()
  return self.combat:isIntangible()
end

function GameEntity:inHitstun()
  return self.combat:inHitstun()
end

function GameEntity:inKnockback()
  return self.combat:inKnockback()
end

-- other
function GameEntity:isInAir()
  if self.movement and self.movement:isEnabled() then
    return self.movement:isInAir()
  end
  return self:getZPosition() > 0
end

function GameEntity:isOnGround()
  return not self:isInAir()
end

function GameEntity:isPersistant()
  return self.persistant
end

return GameEntity