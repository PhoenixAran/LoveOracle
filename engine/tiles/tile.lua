local Class = require 'lib.class'
local lume = require 'lib.lume'
local bit = require 'bit'
local Entity = require 'engine.entities.entity'
local TileType = require('engine.enums.flags.tile_type_flags').enumMap
local GRID_SIZE = 16

local function makeTileEntityName(tileIndexX, tileIndexY, layer)
  return tostring(tileIndexX) .. '_' .. tostring(tileIndexY) .. '-' .. tostring(layer)
end

---@class Tile : Entity
---@field tileData TileData
---@field layer integer
---@field tileIndexX integer
---@field tileIndexY integer
---@field sprite TileSpriteRenderer
local Tile = Class { __includes = Entity,
  init = function(self, tileData, tileIndexX, tileIndexY, layer)
    local zMin, zMax = tileData:getCollisionZRange()
    Entity.init(self, {
      useBumpCoords = true,
      name = makeTileEntityName(layer, tileIndexX, tileIndexY),
      x = (tileIndexX - 1) * GRID_SIZE,
      y = (tileIndexY - 1) * GRID_SIZE,
      w = tileData.w,
      h = tileData.h,
      zMin = zMin,
      zMax = zMax
    })
    -- TODO: check if it has a hurtbox
    -- TODO: make hurtbox
    -- use flyweight pattern via tileData instance
    self.tileData = tileData
    self.layer = layer
    self.tileIndexX = tileIndexX
    self.tileIndexY = tileIndexY
    self.sprite = tileData:getSprite()
    self:setPhysicsLayer('tile')
  end
}

function Tile:getType()
  return 'tile'
end

function Tile:getTileType()
  return self.tileData.tileType
end

function Tile:isTile()
  return true
end

function Tile:getTileData()
  return self.tileData
end

-- function Tile:isActionTile()
--   return false
-- end

-- function Tile:isUpdatable()
--   return false
-- end

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

return Tile