local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'
local vector = require 'engine.math.vector'
local lume = require 'lib.lume'
local rect = require 'engine.math.rectangle'
local Physics = require 'engine.physics'
local DamageInfo = require 'engine.entities.damage_info'
local TablePool = require 'engine.utils.table_pool'

-- helper function
local function setPositionRelativeToEntity(hitbox)
  local ex, ey = hitbox.entity:getPosition()
  hitbox.x = (ex - hitbox.w / 2) + hitbox.offsetX
  hitbox.y = (ey - hitbox.h / 2) + hitbox.offsetY
  hitbox.z = hitbox.entity:getZPosition()
end


---@class Hitbox : BumpBox, Component
---@field offsetX integer
---@field offsetY integer
---@field detectOnly integer
---@field canHitMultiple boolean
---@field useEntityAsSource boolean
---@field damage integer
---@field knockbackTime integer
---@field knockbackSpeed integer
---@field hitstunTime integer
---@field damageInfo DamageInfo
---@field collisionTag string?
---@field queryRectFilter function
local Hitbox = Class { __includes = { BumpBox, Component },
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    BumpBox.init(self, args)
    Component.init(self, entity, args)

    self:signal('hitbox_entered')
    self:signal('damaged_other')
    self:signal('resisted')

    if args.offsetX == nil then args.offsetX = 0 end
    if args.offsetY == nil then args.offsetY = 0 end
    if args.detectOnly == nil then args.detectOnly = false end
    if args.canHitMultiple == nil then args.canHitMultiple = false end
    if args.useEntityAsSource == nil then args.useEntityAsSource = true end
    if args.damage == nil then args.damage = 0 end
    if args.knockbackTime == nil then args.knockbackTime = 0 end
    if args.knockbackSpeed == nil then args.knockbackSpeed = 0 end
    if args.hitstunTime == nil then args.hitstunTime = 0 end

    self.offsetX = args.offsetX
    self.offsetY = args.offsetY
    self.detectOnly = args.detectOnly
    self.canHitMultiple = args.canHitMultiple
    -- use entity's position as source position
    self.useEntityAsSource = args.useEntityAsSource
    self.collisionTag = args.collisionTag
    self.damage = args.damage
    self.knockbackTime = args.knockbackTime
    self.knockbackSpeed = args.knockbackSpeed
    self.hitstunTime = args.hitstunTime

    self.damageInfo = DamageInfo()
    self.damageInfo.damage = self.damage
    self.damageInfo.knockbackTime = self.knockbackTime
    self.damageInfo.knockbackSpeed = self.knockbackSpeed
    self.damageInfo.hitstunTime = self.hitstunTime

    -- set the physics mask for this hitbox
    self:setPhysicsLayer('hitbox')
    self:setCollidesWithLayer('hitbox')

    local closureSelf = self
    local canCollide = BumpBox.canCollide
    local function queryRectHitboxFilter(item)
      if item == closureSelf then
        return nil -- don't collide with self
      end
      if canCollide(closureSelf, item) then
        if item.getType and item:getType() == 'hitbox' then
          return true
        end
      end
      -- don't report
      return nil
    end
    self.queryRectFilter = queryRectHitboxFilter
  end
}

function Hitbox:getType()
  return 'hitbox'
end

function Hitbox:onTransformChanged()
  setPositionRelativeToEntity(self)
  if self.registeredWithPhysics then
    Physics:update(self, self.x, self.y, self.w, self.h)
  end
end

function Hitbox:setCollisionTag(collisionTag)
  self.collisionTag = collisionTag
end

function Hitbox:getCollisionTag()
  return self.collisionTag
end

function Hitbox:entityAwake()
  assert(not self.registeredWithPhysics)
  Physics:add(self, self.x, self.y, self.w, self.h)
  self.registeredWithPhysics = true
end

function Hitbox:onRemoved()
  if self.registeredWithPhysics then
    Physics:remove(self)
    self.registeredWithPhysics = false
  end
end

function Hitbox:onEnabled()
  if not self.registeredWithPhysics then
    Physics:add(self, self.x, self.y, self.w, self.h)
    self.registeredWithPhysics = true
  end
end

function Hitbox:onDisabled()
  if self.registeredWithPhysics then
    Physics:remove(self)
    self.registeredWithPhysics = false
  end
end

function Hitbox:update()
  if not self.detectOnly then
    local items, len = Physics:queryRect(self.x, self.y, self.w, self.h, self.queryRectFilter)
    if 0 < len then
      for _, item in ipairs(items) do
        self:reportHitboxCollision(item)
      end
    end
    Physics.freeTable(items)
  end
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

---@param x number
---@param y number
function Hitbox:setOffset(x, y)
  self.offsetX = x
  self.offsetY = y
  setPositionRelativeToEntity(self)
  if self.registeredWithPhysics then
    Physics:update(self, self.x, self.y, self.w, self.h)
  end
end

---@param width integer
---@param height integer
function Hitbox:resize(width, height)
  self.x, self.y, self.w, self.h = rect.resizeAroundCenter(self.x, self.y, self.w, self.h, width, height)
  setPositionRelativeToEntity(self)
  if self.registeredWithPhysics then
    Physics:update(self, self.x, self.y, self.w, self.h)
  end
end

---sets offset and resizes hitbox
---@param offsetX number
---@param offsetY number
---@param width integer
---@param height integer
function Hitbox:move(offsetX, offsetY, width, height)
  self.offsetX = offsetX
  self.offsetY = offsetY
  setPositionRelativeToEntity(self)
  self.x, self.y, self.w, self.h = rect.resizeAroundCenter(self.x, self.y, self.w, self.h, width, height)
  if self.registeredWithPhysics then
    Physics:update(self, self.x, self.y, self.w, self.h)
  end
end

---raise the hitbox hitboxEntered signal
---@param hitbox Hitbox
function Hitbox:reportHitboxCollision(hitbox)
  self:emit('hitbox_entered', hitbox)
end

---notify that this hitbox inflicted damage
---@param hitbox Hitbox
function Hitbox:notifyDidDamage(hitbox)
  self:emit('damaged_other', hitbox)
end

---notify that this hitbox has been resisted
---used to let the owner know to stop the attack or something
---@param hitbox Hitbox
function Hitbox:notifyResisted(hitbox)
  self:emit('notify_resisted', hitbox)
end

function Hitbox:debugDraw()
  local a = .25
  if self.enabled then
    if self.detectOnly then
      love.graphics.setColor(1, 0.5, 0, a) -- Orange fill
      love.graphics.rectangle('fill', self.x, self.y - self.z, self.w, self.h)
      love.graphics.setColor(0.8, 0.4, 0) -- Darker orange outline
      love.graphics.rectangle('line', self.x, self.y - self.z, self.w, self.h)
    else
      love.graphics.setColor(176 / 255, 35 / 255, 82 / 255, a)
      love.graphics.rectangle('fill', self.x, self.y - self.z, self.w, self.h)
      love.graphics.setColor(120 / 255, 22 / 255, 54 / 255)
      love.graphics.rectangle('line', self.x, self.y - self.z, self.w, self.h)
    end
  else
    love.graphics.setColor(116 / 255, 116 / 255, 117 / 255)
    love.graphics.rectangle('fill', self.x, self.y - self.z, self.w, self.h)
    love.graphics.setColor(55 / 255, 55 / 255, 56 / 255)
    love.graphics.rectangle('line', self.x, self.y - self.z, self.w, self.h)
  end
  love.graphics.setColor(1, 1, 1)
end

return Hitbox