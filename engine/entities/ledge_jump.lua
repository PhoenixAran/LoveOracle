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
    Entity.init(self)
    self.direction4 = args.direction
    self:setPhysicsLayer('ledge_jump')
    self:setCollidesWithLayer('player')
  end
}

function LedgeJump:getType()
  return 'ledge_leap'
end

function LedgeJump:getCollisionTag()
  return 'ledge_jump'
end

return LedgeJump