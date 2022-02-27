local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'
local vector = require 'lib.vector'
local lume = require 'lib.lume'
local Physics = require 'engine.physics'
local DamageInfo = require 'engine.entities.damage_info'
local TablePool = require 'engine.utils.table_pool'

local Hitbox = Class { __includes = { BumpBox, Component },
  --init = function(self, entity, enabled, bumpBoxArgs, hitBoxArgs)
  init = function(self, entity, args)
    BumpBox.init(self, args.x, args.y, args.w,
        args.h, args.zRange, args.collisionTag)
    Component.init(self, entity, args)

    self:signal('hitboxEntered')
    self:signal('damagedOther')
    self:signal('resisted')

    if args.detectOnly == nil then args.detectOnly = false end
    if args.canHitMultiple == nil then args.canHitMultiple = false end
    if args.useEntityAsSource == nil then args.useEntityAsSource = true end
    if args.damage == nil then args.damage = 0 end
    if args.knockbackTime == nil then args.knockbackTime = 0 end
    if args.knockbackSpeed == nil then args.knockbackSpeed = 0 end
    if args.hitstunTime == nil then args.hitstunTime = 0 end

    self.detectOnly = args.detectOnly
    self.canHitMultiple = args.canHitMultiple
    -- use entity's position as source position
    self.useEntityAsSource = args.useEntityAsSource

    self.damage = args.damage
    self.knockbackTime = args.knockbackTime
    self.knockbackSpeed = args.knockbackSpeed
    self.hitstunTime = args.hitstunTime

    self.damageInfo = DamageInfo()
    self.damageInfo.damage = self.damage
    self.damageInfo.knockbackTime = self.knockbackTime
    self.damageInfo.knockbackSpeed = self.knockbackSpeed
    self.damageInfo.hitstunTime = self.hitstunTime
  end
}

function Hitbox:getType()
  return 'hitbox'
end

function Hitbox:getCollisionTag()
  return 'hitbox'
end

function Hitbox:onTransformChanged()
  local ex, ey = self.entity:getPosition()
  self.x = ex - self.w / 2
  self.y = ey - self.h / 2
  Physics.update(self)
end

function Hitbox:entityAwake()
  assert(not self.registeredWithPhysics)
  Physics.add(self)
  self.registeredWithPhysics = true
end

function Hitbox:onRemoved()
  if self.registeredWithPhysics then
    Physics.remove(self)
    self.registeredWithPhysics = false
  end
end

function Hitbox:onEnabled()
  if not self.registeredWithPhysics then
    Physics.add(self)
    self.registeredWithPhysics = true
  end
end

function Hitbox:onDisabled()
  if self.registeredWithPhysics then
    Physics.remove(self)
    self.registeredWithPhysics = false
  end
end

function Hitbox:update(dt)
  if self.detectOnly then
    return
  end
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

function Hitbox:getDamageInfo()
  if self.useEntityAsSource then
    local ex, ey = self.entity:getPosition()
    self.damageInfo.sourceX = ex
    self.damageInfo.sourceY = ey
  else
    self.damageInfo.sourceX = self.x + self.w / 2
    self.damageInfo.sourceY = self.y + self.y / 2
  end
  return self.damageInfo
end

-- raise the hitbox hitboxEntered signal
function Hitbox:reportCollision(hitbox)
  self:emit('hitboxEntered', hitbox)
end

-- notify that this hitbox inflicted damage
function Hitbox:notifyDidDamage(hitbox)
  self:emit('damagedOther', hitbox)
end

-- notify that this hitbox has been resisted
-- used to let the owner know to stop the attack or something
function Hitbox:notifyResisted(hitbox)
  self:emit('notifyResisted', hitbox)
end

return Hitbox