local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
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
local Enemy = Class { __includes = MapEntity,
  init = function(self, args)
    MapEntity.init(self, args)

    -- environment stuff
    self.canFallInHole = true
    self.canSwimInLava = false
    self.canSwimInWater = false -- note this is only for deep water
  end
}

function Enemy:getType()
  return 'enemy'
end

function Enemy:getCollisionTag()
  return 'enemy'
end

-- -- some utility functions for enemy scripts
-- function Enemy:canMoveInDirection(x, y)
--   local canMove = true
--   if y == nil then
--     -- x is radian value
--     x, y = math.cos(x), math.sin(x)
--   end
--   x, y = vector.normalize(x, y)
--   local hits = TablePool.obtain()
--   -- check for any tiles in the way
--   local tileLayer = PhysicsFlags:get('tile')
--   local ex, ey = self:getPosition()
--   local velx, vely = vector.mul(x, y, self.movement:getSpeed())
--   local potentialx, potentialy = ex + velx, ey + vely
--   -- check for anything the entity can collide with is in the way
--   if Physics.rectcast(potentialx, potentialy, self.w, self.h, self.physicsLayer, self.zRange.min, self.zRange.max) then
--     for _, otherBox in ipairs(hits) do
--       if otherBox:isTile() and self.collisionTiles[otherBox:getTileType()] then
--         canMove = false
--         break
--       else
--         canMove = false
--         break
--       end
--     end
--   end
--   -- check for any hazard tiles
--   -- TODO Singletons.entities.getTopTile(vecx, vecy):isHazardTile() or something along these lines
--   TablePool.free(hits)
--   return canMove
-- end


return Enemy