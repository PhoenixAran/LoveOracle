local Class = require 'lib.class'
local vector = require 'engine.math.vector'
local lume = require 'lib.lume'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'
local Physics = require 'engine.physics'

local function defaultColliderMoveFilter(item, other)
  return 'cross'
end

-- Use this if you want to have an additional 'collider' for you entity 
-- If your entity just needs one collider, just use the entity itself since it is a bumpbox
-- Main use case (and probably only use case) for this component is for entities to have different
-- sized collision box for screen edge borders
---@class Collider : BumpBox, Component
---@field offsetX number
---@field offsetY number
---@field moveFilter function
local Collider = Class { __includes = { BumpBox, Component },
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    self.offsetX = args.offsetX or 0
    self.offsetY = args.offsetY or 0
    args.x = args.x + self.offsetX
    args.y = args.y + self.offsetY
    BumpBox.init(self, args)
    Component.init(self, entity, args)
    self.moveFilter = defaultColliderMoveFilter
  end
}

function Collider:getType()
  return 'collider'
end

function Collider:onTransformChanged()
  local ex, ey = self.entity:getPosition()
  self.x = ex + self.offsetX - self.w / 2
  self.y = ey + self.offsetY - self.h / 2
  if self.registeredWithPhysics then
    Physics:update(self, self.x, self.y, self.w, self.h)
  end
end

function Collider:entityAwake()
  if not self.registeredWithPhysics then
    Physics:add(self, self.x, self.y, self.w, self.h)
    self.registeredWithPhysics = true
  end
end

function Collider:onRemoved()
  if self.registeredWithPhysics then
    Physics:remove(self)
    self.registeredWithPhysics = false
  end
end

function Collider:onEnabled()
  if not self.registeredWithPhysics then
    Physics:add(self, self.x, self.y, self.w, self.h)
    self.registeredWithPhysics = true
  end
end

function Collider:onDisabled()
  if self.registeredWithPhysics then
    Physics:remove(self)
    self.registeredWithPhysics = false
  end
end

function Collider:debugDraw()
  local positionX, positionY = self:getBumpPosition()
  love.graphics.setColor(20 / 255, 219 / 255, 189 / 255, 150 / 255)
  love.graphics.rectangle('line', positionX, positionY, self.w, self.h)
  love.graphics.setColor(1, 1, 1, 1)
end

return Collider