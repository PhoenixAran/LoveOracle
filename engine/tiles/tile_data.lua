local Class = require 'lib.class'
local bit = require 'bit'

local TileData = Class {
  init = function(self, id)
    self.id = id
    self.name =  ''
    
    self.sprite = nil
    self.isAnimated = false
    
    self.collisionRect = { x = 0, y = 0, w = 16, y = 16 }
    self.hurtRect = { x = 0, y = 0, w = 16, y = 16 }
    self.tileFlags = { }
    self.physicsLayer = -1
    self.collidesWithLayer = -1
    
    -- default type to assign this tile data too
    self.tileType = 'tile'  
  end
}

function TileData:getId()
  return self.id
end

function TileData:isAnimated()
  return self.isAnimated
end

function TileData:getSprite()
  return self.sprite
end

function TileData:setCollisionDimension(x, y, w, h)
  self.collisionRect.x = x
  self.collisionRect.y = y
  self.collisionRect.w = w
  self.collisionRect.h = h
end

function TileData:setHurtBoxDimensions(x, y, w, h)
  self.hurtRect.x = x
  self.hurtRect.y = y
  self.hurtRect.w = w
  self.hurtRect.h = h
end

function TileData:getTileFlags(flag)
  return self.tileFlags
end

function TileData:getPhysicsLayer()
  return self.physicsLayer
end

function TileData:getCollidesWithLayer()
  return self.collidesWithLayer
end

return TileData