local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'
local vector = require 'lib.vector'
local lume = require 'lib.lume'
local Physics = require 'engine.physics'

local Hitbox = Class { __includes = { BumpBox, Component },
  init = function(self, entity, enabled, bumpBoxArgs, hitBoxArgs)
    BumpBox.init(self, bumpBoxArgs.x, bumpBoxArgs.y, bumpBoxArgs.w, 
                 bumpBoxArgs.h, bumpBoxArgs.zRange, bumpBoxArgs.collisionTag)
    Component.init(self, entity, enabled)
    
    self:signal('hitboxEntered')
    self:signal('damagedOther')
    self:signal('resisted')

    self.detectOnly = hitBoxArgs.detectOnly or false
    self.canHitMultiple = hitBoxArgs.canHitMultiple or false
    -- use entity's position as source position
    self.useEntityAsSource = hitBoxArgs.useEntityAsSource or true

    self.damage = hitBoxArgs.damage or 5
    self.knockbackTime = hitBoxArgs.knockbackTime or 30
    self.knockbackSpeed = hitBoxArgs.knockbackSpeed or 150
    self.hitstunTime = hitBoxArgs.hitstunTime or 30
  end
}

function Hitbox:transformChanged()
  local ex, ey = self.entity:getBumpPosition()
  self.x = ex
  self.y = ey
  Physics.update(self)
end 

function Hitbox:update(dt)
  local neighbors = Physics.boxcastBroadphase(self, self.x, self.y, self.w, self.h)
  if lume.count(neighbors) > 0 then
    if self.canHitMultiple then
      for _, neighbor in ipairs(neighbors) do
        neighbor:reportCollision(self)
      end
    else
      neighbors[1]:reportCollision(self)
    end
  end
  TablePool.free(neighbors)
end

-- raise the hitbox hitboxEntered signal
function Hitbox:reportCollision(hitbox)
  self:emit('hitboxEntered', hitbox)
end

-- notify that this hitbox inflicted damage
function Hitbox:notifyDidDamage(hitbox)
  self:emit('damagedOther', hitbox)
end

--notify that this hitbox has been resisted
-- used to let the owner know to stop the attack or something
function Hitbox:notifyResisted(hitbox)
  self:emit('notifyResisted', hitbox)
end

return Hitbox