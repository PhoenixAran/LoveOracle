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
local TileTypes = require 'engine.enums.tile_type'
local BitTag = require 'engine.utils.bit_tag'

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

-- some utility functions for enemy scripts
function Enemy:canMoveInDirection(x, y)
  local canMove = true
  if y == nil then
    -- x is radian value
    x, y = math.cos(x), math.sin(x)
  end
  x, y = vector.normalize(x, y)
  local hits = TablePool.obtain()
  -- check for any tiles in the way
  local tileLayer = BitTag.get('tile')
  local ex, ey = self:getPosition()
  local velx, vely = vector.mul(x, y, self.movement:getSpeed())
  local potentialx, potentialy = ex + velx, ey + vely
  -- check for anything the entity can collide with is in the way
  if Physics.rectcast(potentialx, potentialy, self.w, self.h, self.physicsLayer, self.zRange.min, self.zRange.max) then
    for _, otherBox in ipairs(hits) do
      if otherBox:isTile() then
        local tileType = otherBox:getTypeType()
        -- check for solid types, or hazard tiles
        if self.collisionTiles[otherBox:getTileType()] then
          canMove = false
          break
        elseif self.canFallInHole and tileType == TileTypes.Hole then
          canMove = false
          break
        elseif (not self.canSwimInLava) and (tileType == TileTypes.Lava or tileType == TileTypes.LavaFall) then
          canMove = false
          break
        elseif (not self.canSwimInWater) and (tileType == TileTypes.DeepWater or tileType == TileTypes.ocean) then
          canMove = false
          break
        end
      else
        canMove = false
        break
      end
    end
  end
  TablePool.free(hits)
  return canMove
end


return Enemy