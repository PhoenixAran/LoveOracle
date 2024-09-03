local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local Physics = require 'engine.physics'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TablePool = require 'engine.utils.table_pool'
local vector = require 'engine.math.vector'
local lume = require 'lib.lume'

local Direction4 = require 'engine.enums.direction4'

---@class LedgeJump : Entity
---@field direction integer
---@field moveX integer
local LedgeJump = Class { __includes = Entity,
  init = function(self, args)
    args.w = args.width
    args.h = args.height
    args.useBumpCoords = true
    Entity.init(self, args)
    self:setPhysicsLayer('ledge_jump')
  end
}

function LedgeJump:getType()
  return 'ledge_jump'
end

function LedgeJump:getCollisionTag()
  return 'ledge_jump'
end

function LedgeJump:draw()
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

return LedgeJump