local Class = require 'lib.class'
local lume = require 'lib.lume'
local bit = require 'bit'
local Entity = require 'engine.entities.entity'
local TileType = require('engine.enums.flags.tile_type_flags').enumMap
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local GRID_SIZE = require('constants').GRID_SIZE
local Singletons = require 'engine.singletons'
local vec2 = require 'engine.math.vector'
local uuid = require 'engine.utils.uuid'

---@class Tile : Entity
---@field tileData TileData
---@field layer integer
---@field index integer index in 1d array
---@field tileIndexX integer x index in 2d array
---@field tileIndexY integer y index in 2d array
---@field topTile boolean if this given tile is the top tile
---@field sprite TileSpriteRenderer
local Tile = Class { __includes = Entity,
  init = function(self, tileData, index, tileIndexX, tileIndexY, layer)
    local zMin, zMax = tileData:getCollisionZRange()
    Entity.init(self, {
      useBumpCoords = true,
      name = uuid(),
      x = (tileIndexX - 1) * GRID_SIZE,
      y = (tileIndexY - 1) * GRID_SIZE,
      w = GRID_SIZE,
      h = GRID_SIZE,
      zMin = zMin,
      zMax = zMax
    })
    -- TODO: check if it has a hurtbox
    -- TODO: make hurtbox
    -- use flyweight pattern via tileData instance
    self.tileData = tileData
    self.index = index
    self.tileIndexX = tileIndexX
    self.tileIndexY = tileIndexY
    self.layer = layer
    self.sprite = tileData:getSprite()
    self.topTile = false
    self:setPhysicsLayer('tile')

    -- interact vars
    self.minBoomerangLevel = 0
    self.minSwordLevel = 0

    -- signals
    self:signal('tile_destroyed')
    self:signal('entity_created')
  end
}

function Tile:getType()
  return 'tile'
end

function Tile:getTileType()
  return self.tileData.tileType
end

function Tile:getConveyorVelocity()
  local td = self.tileData
  return vec2.mul(td.conveyorSpeed, vec2.normalize(td.conveyorVectorX, td.conveyorVectorY))
end

function Tile:isTile()
  return true
end

function Tile:getTileData()
  return self.tileData
end

function Tile:getMinSwordLevel()
  return self.tileData.minSwordLevel
end

function Tile:getMinBoomerangLevel()
  return self.tileData.minBoomerangLevel
end

-- function Tile:isActionTile()
--   return false
-- end

-- function Tile:isUpdatable()
--   return false
-- end

function Tile:isWall()
  return bit.band(self.tileData.tileType, TileType.Wall) ~= 0
end

function Tile:isAnimated()
  return self.sprite:isAnimated()
end

function Tile:getSprite()
  return self.sprite
end

function Tile:draw()
  local x, y = self:getPosition()
  self.sprite:draw(x, y)
end

function Tile:isTopTile()
  return Singletons.roomControl:isTopTile(self)
end


-- interaction methods

---called when the player presses the interact button on this tile
---@param swordItem Item
function Tile:onSwordHit(swordItem)
  if self.tileData.minSwordLevel < swordItem.level then
    -- TODO
  end
end




return Tile