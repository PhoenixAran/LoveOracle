local Class = require 'lib.class'
local lume = require 'lib.lume'
local bit = require 'bit'
local BitTag = require 'engine.utils.bit_tag'
local Entity = require 'engine.entities.entity'
local TileType = require 'engine.enums.tile_type'
local GRID_SIZE = 16

local function makeTileEntityName(tileIndexX, tileIndexY, layer)
  return tostring(tileIndexX) .. '_' .. tostring(tileIndexY) .. '-' .. tostring(layer)
end

local Tile = Class { __includes = Entity,
  init = function(self, tileData,  tileIndexX, tileIndexY, layer)
    local name = makeTileEntityName(layer, tileIndexX, tileIndexY)
    local collisionRectZRangeX, collisionRectZRangeY = tileData:getCollisionZRange()
    local collisionRectZRange = { min = collisionRectZRangeX, max = collisionRectZRangeY }
    local collisionRect = { w = tileData.w, h = tileData.h }
    Entity.init(self, name, true, true, collisionRect, collisionRectZRange)
    self:setPositionWithBumpCoords((tileIndexX - 1) * GRID_SIZE, (tileIndexY - 1) * GRID_SIZE)
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

function Tile:getSprite()
  return self.sprite
end

function Tile:draw()
  local x, y = self:getPosition()
  self.sprite:draw(x, y)
end

return Tile