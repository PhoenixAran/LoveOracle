local Class = require 'lib.class'
local lume = require 'lib.lume'
local bit = require 'bit'
local BitTag = require 'engine.utils.bit_tag'
local Entity = require 'engine.entities.bump_box'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.sprite'
local TileData = require 'engine.tiles.tile_data'

local Tile = Class { __includes = Entity,
  init = function(self, tileData, layer, tileIndexX, tileIndexY)
    local name = tostring(layer) .. '_' .. tostring(tileIndexX) .. '_' .. tostring(tileIndexY)
    local collisionRectZRangeX, collisionRectZRangeY = tileData:getCollisionZRange()
    local collisionRectZRange = { min = collisionRectZRangeX, max = collisionRectZRangeY }
    Entity.init(self, name, true, true, tileData.collisionRect, collisionRectZRange)
    
    -- TODO: check if it has a hurtbox
    -- TODO: make hurtbox
    
    -- use flyweight pattern via tileData instance
    self.data = tileData
    self.layer = layer
    self.tileIndexX = tileIndexX
    self.tileIndexY = tileIndexY
  end
}

function Tile:getType()
  return 'tile'
end

function Tile:isTile()
  return true
end

function Tile:getTileData()
  return self.data
end

-- function Tile:isActionTile()
--   return false
-- end

function Tile:isUpdatable()
  return false
end

function Tile:getSprite()
  return self.tileData:getSprite()
end

function Tile:draw()
  self.tileSprite:draw(self:getPosition())
end

function Tile.registerTileEntityType(tileEntityClass)
  TileData.registerTileEntityType(tileEntityClass)
end

Tile.registerTileEntityType(Tile)

return Tile