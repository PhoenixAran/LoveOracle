local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'entine.entities.component'

local HitBox = Class { __includes = { BumpBox, Component },
  init = function(self, entity, enabled, rect, collisionTag)
    if enabled == nil then enabled = true end
    if rect == nil then
      rect = { }
      rect.x = 0
      rect.y = 0
      rect.w = 1
      rect.h = 1
    else 
      if rect.x == nil then rect.x = 0 end
      if rect.y == nil then rect.y = 0 end
      if rect.w == nil then rect.w = 1 end
      if rect.h == nil then rect.h = 1 end
    end
    BumpBox.init(self, rect, collisionTag)
    Component.init(self, entity, enabled)
    
    self:signal('hitboxEntered')
    self:signal('damagedOther')
    self:signal('resisted')
    
    self.registeredWithPhysics = false
    
    self.canHitMultiple = true
    self.detectOnly = false
    self.useParentAsSource = false
    self.collidesOnlyWithSameLevels = false
    
    self.damage = 1
    self.knockbackTime = 20
    self.knockbackSpeed = 100
    self.hitstunTime = 10
  end
}

function HitBox:getType()
  return 'hit_box'
end

function HitBox:transformChanged()
  self.x, self.y = self.entity:getPosition()
  physics.update(self)
end

function HitBox:resize(width, height)
  physics.remove(self)
  self.x, self.y, self.w, self.h = rect.resizeAroundCenter(self.x, self.y, self.w, self.h, width, height)
  physics.add(self)
end

function HitBox:entityAwake()
  assert(not self.registeredWithPhysics)
  physics.add(self)
  self.registeredWithPhysics = true
end

function HitBox:entityRemoved(screen)
  if self.registeredWithPhysics then
    physics.remove(self)
    self.registeredWithPhysics = false
  end
end

function HitBox:onRemoved()
  if self.registeredWithPhysics then
    physics.remove(self)
    self.registeredWithPhysics = false
  end
end

function HitBox:onEnabled()
  if not self.registeredWithPhysics then
    physics.add(self)
    self.registeredWithPhysics = true
  end
end

function HitBox:onDisabled()
  if self.registeredWithPhysics then
    physics.remove(self)
    self.registeredWithPhysics = false
  end 
end

function HitBox:update(dt)
  if self.detectOnly then return end
  local bx, by, bw, bh self:getBounds()
  local otherBoxes = physics.boxcastBroadphase(self, bx, by, bw, bh)
  if #otherBoxes > 0 then
    if self.canHitMultiple then 
      for _, box in ipairs(otherBoxes) do
        box:reportCollision(self)
      end
    else
      otherBoxes[1]:reportCollision(self)
    end
  end
end

function HitBox:reportCollision(other)
  self:emit('hitboxEntered', self, other)
end

function HitBox:notifyDidDamage(other)
  self:emit('damageOther', self, other)
end

function HitBox:notifyResisted(other)
  self:emit('resisted', self, other)
end

return HitBox