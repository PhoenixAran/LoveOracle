local Class = require 'lib.class'
local vector = require 'lib.vector'
local lume = require 'lib.lume'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'
local Physics = require 'engine.physics'

-- Use this if you want to have an additional 'collider' for you entity 
-- If your entity just needs one collider, just use the entity itself since it is a bumpbox
-- Main use case (and probably only use case) for this component is for entities to have different
-- sized collision box for screen edge borders
local Collider = Class { __includes = { BumpBox, Component },
  init = function(self, entity, enabled, colliderArgs)
    BumpBox.init(self, colliderArgs.x + colliderArgs.offsetX, colliderArgs.y + colliderArgs.offsetY,
                colliderArgs.w, colliderArgs.h, colliderArgs.zRange, colliderArgs.collisionTag)
    Component.init(self, entity, enabled)
    self.offsetX = colliderArgs.offsetX or 0
    self.offsetY = colliderArgs.offsetY or 0
    self.detectOnly = colliderArgs.detectOnly or false
  end
}

function Collider:getType()
  return 'collider'
end

function Collider:onTransformChanged()
  local ex, ey = self.entity:getPosition()
  self.x = ex + self.offsetX - self.w / 2
  self.y = ey + self.offsetY - self.h / 2
  if not self.detectOnly then
    Physics.update(self)
  end
end

function Collider:entityAwake()
  assert(not self.registeredWithPhysics)
  if not self.detectOnly then
    Physics.add(self)
    self.registeredWithPhysics = true
  end
end

function Collider:onRemoved()
  if self.registeredWithPhysics then
    Physics.remove(self)
    self.registeredWithPhysics = false
  end
end

function Collider:onEnabled()
  if not self.registeredWithPhysics then
    Physics.add(self)
    self.registeredWithPhysics = true
  end
end

function Collider:onDisabled()
  if self.registeredWithPhysics then
    Physics.remove(self)
    self.registeredWithPhysics = false
  end
end

return Collider