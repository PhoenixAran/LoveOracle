local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local rect = require 'engine.math.rectangle'
local TablePool = require 'engine.utils.table_pool'
local MapEntity = require 'engine.entities.map_entity'
local Physics = require 'engine.physics'
local Collider = require 'engine.components.collider'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'

---@class Enemy : MapEntity
---@field canFallInHole boolean
---@field canSwimInLava boolean
---@field canSwimInWater boolean
---@field jumpGravity number
---@field jumpZVelocity number
local Enemy = Class { __includes = MapEntity,
  ---@param self Enemy
  ---@param args table
  init = function(self, args)
    MapEntity.init(self, args)

    -- environment configuration
    self.canFallInHole = true
    self.canSwimInLava = false
    self.canSwimInWater = false -- note this is only for deep water

    -- jump behaviour configuration
    self.jumpGravity = args.jumpZGravity or 8
    self.jumpZVelocity = args.jumpZVelocity or 2
  end
}

function Enemy:getType()
  return 'enemy'
end

function Enemy:getCollisionTag()
  return 'enemy'
end

-- in game behavior action helper functions
function Enemy:jump()
  self.movement.gravity = self.jumpGravity
  self.movement:setZVelocity(self.jumpZVelocity)
end

-- some helper functions for classes that inherit Enemy
function Enemy:canMoveInDirection(x, y)
  local canMove = true
  if y == nil then
    -- x is radian value
    x, y = math.cos(x), math.sin(x)
  end
  x, y = vector.normalize(x, y)
end

function Enemy:getRandomDirection4()
  
end

function Enemy:getRandomDirection8()

end

function Enemy:getRandomVector2(normalized)

end









return Enemy