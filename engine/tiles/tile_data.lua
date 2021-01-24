local Class = require 'lib.class'
local bit = require 'bit'
local TileType = require 'engine.tiles.tile_type'
local BitTag = require 'engine.utils.bit_tag'
local SpriteBank = require 'engine.utils.sprite_bank'

-- used to validate tile types provided by data scripter
local TileTypeInverse = lume.invert(TileType)


local TileData = Class {
  init = function(self, id)
    self.id = id
    self.name =  ''
    self.type = TileType.Ground
    
    self.sprite = nil
    self.isAnimated = false
    
    self.collisionRect = { x = 0, y = 0, w = 16, y = 16 }
    self.hurtRect = { x = 0, y = 0, w = 16, y = 16 }

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

function TileData:setSprite(name)
  if self:isAnimated() then
    self.sprite = SpriteBank.getAnimation(name)
  else
    self.sprite = SpriteBank.getSprite(name)
  end
end

function TileData:getCollisionDimensions(x, y, w, h)
  return self.collisionRect.x, self.collisionRect.y, self.collisionRect.w, self.collisionRect.h
end

function TileData:setCollisionDimension(x, y, w, h)
  self.collisionRect.x = x
  self.collisionRect.y = y
  self.collisionRect.w = w
  self.collisionRect.h = h
end

function TileData:getHurtboxDimensions(x, y, w, h)
  return self.hurtRect.x, self.hurtRect.y, self.hurtRect.w, self.hurtRect.h
end

function TileData:setHurtBoxDimensions(x, y, w, h)
  self.hurtRect.x = x
  self.hurtRect.y = y
  self.hurtRect.w = w
  self.hurtRect.h = h
end

-- layer stuff
function BumpBox:getCollidesWithLayer()
  return self.collidesWithLayer
end

function BumpBox:getPhysicsLayer()
  return self.physicsLayer
end

function BumpBox:setCollidesWithLayerExplicit(value)
  self.collidesWithLayer = value
end

function BumpBox:setCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.collidesWithLayer = bit.bor(self.collidesWithLayer, BitTag.get(v).value)
    end
  else
    self.collidesWithLayer = bit.bor(self.collidesWithLayer, BitTag.get(layer).value)
  end
end

function BumpBox:unsetCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.collidesWithLayer = bit.band(self.collidesWithLayer, bit.bnot(BitTag.get(v).value))
    end
  else
    self.collidesWithLayer = bit.band(self.collidesWithLayer, bit.bnot(BitTag.get(layer).value))
  end
end

function BumpBox:setPhysicsLayerExplicit(value)
  self.physicsLayer = value
end

function BumpBox:setPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.bor(self.physicsLayer, BitTag.get(v).value)
    end
  else
    self.physicsLayer = bit.bor(self.physicsLayer, BitTag.get(layer).value)
  end
end

function BumpBox:unsetPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(BitTag.get(v).value))
    end
  else
    self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(BitTag.get(layer).value))
  end
end

return TileData