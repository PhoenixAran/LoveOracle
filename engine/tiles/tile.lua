local Class = require 'lib.class'
local lume = require 'lib.lume'
local bit = require 'bit'

local Entity = require 'engine.entities.bump_box'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.sprite'

local Tile = Class { __includes = Entity,
  init = function(self, tileData, posX, posY, tileEntityName)
    local collisionRectZRangeX, collisionRectZRangeY = tileData:getCollisionZRange()
    local collisionRectZRange = { min = collisionRectZRangeX, max = collisionRectZRangeY }
    Entity.init(self, tileId, true, true, tileData.collisionRect, collisionRectZRange)
    
    -- TODO check if it has a hurtbox
    -- TODO make hurtbox
    
    
    
    -- use flyweight pattern via tileData instance
    self.data = tileData
  end
}

function Tile:getType()
  return 'tile'
end

function Tile:getTileData()
  return self.data
end

function Tile:isActionTile()
  return false
end

function Tile:isUpdatable()
  return false
end

function Tile:getSprite()
  return self.tileData:getSprite()
end

function Tile:draw()
  self.tileSprite.draw(self:getPosition())
end

function Tile:pick()
  return nil
end

return Tile