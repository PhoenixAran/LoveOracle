local Class = require 'lib.class'
local lume = require 'lib.lume'
local bit = require 'bit'
local TileType = require 'engine.tiles.tile_type'
local BitTag = require 'engine.utils.bit_tag'
local SpriteBank = require 'engine.utils.sprite_bank'

-- used to validate tile types provided by data scripter
local TileTypeInverse = lume.invert(TileType)
local Templates = { }

local TileData = Class {
  init = function(self)
    self.name = nil
    self.tileType = TileType.Normal
    
    self.sprite = nil
    self.animated = false
    self.hitbox = false
    
    self.collisionRect = { x = 0, y = 0, w = 16, y = 16 }
    self.hitRect = { x = 0, y = 0, w = 16, y = 16 }

    self.physicsLayer = 0
    self.collidesWithLayer = 0
    
    self.hitPhysicsLayer = 0
    self.hitCollidesWithLayer = 0 
    
    -- default type to assign this tile data too
    -- when instancing actual tile in game
    self.tileClassType = 'tile'
    
    self.physicsLayer = bit.bor(self.physicsLayer, BitTag.get('tile').value)   
  end
}

-- do not confuse with tiletype!
function TileData:getType()
  return 'tile_data'
end

function TileData:getTileType()
  return self.tileType
end

function TileData:getTileClassType()
  return self.tileClassType
end

function TileData:getName()
  return self.name
end

function TileData:setName(name)
  self.name = name
end

function TileData:setTileClassType(value)
  self.tileClassType = value
end

function TileData:setTileType(tileType)
  assert(TileTypeInverse[tileType], tileType .. ' is not a valid tile type')
  self.tileType = tileType
end

function TileData:isAnimated()
  return self.animated
end

function TileData:setAnimated(value)
  self.animated = value
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

function TileData:hasHurtbox()
  return self.hurtbox
end

function TileData:setHurtbox(value)
  self.hurtbox = value
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

-- collision layer stuff
function TileData:getCollidesWithLayer()
  return self.collidesWithLayer
end

function TileData:getPhysicsLayer()
  return self.physicsLayer
end

function TileData:setCollidesWithLayerExplicit(value)
  self.collidesWithLayer = value
end

function TileData:setCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.collidesWithLayer = bit.bor(self.collidesWithLayer, BitTag.get(v).value)
    end
  else
    self.collidesWithLayer = bit.bor(self.collidesWithLayer, BitTag.get(layer).value)
  end
end

function TileData:unsetCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.collidesWithLayer = bit.band(self.collidesWithLayer, bit.bnot(BitTag.get(v).value))
    end
  else
    self.collidesWithLayer = bit.band(self.collidesWithLayer, bit.bnot(BitTag.get(layer).value))
  end
end

function TileData:setPhysicsLayerExplicit(value)
  self.physicsLayer = value
end

function TileData:setPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.bor(self.physicsLayer, BitTag.get(v).value)
    end
  else
    self.physicsLayer = bit.bor(self.physicsLayer, BitTag.get(layer).value)
  end
end

function TileData:unsetPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(BitTag.get(v).value))
    end
  else
    self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(BitTag.get(layer).value))
  end
end

-- hurtbox collision layer
function TileData:getHitBoxCollidesWithLayer()
  return self.hitCollidesWithLayer
end

function TileData:getHitBoxPhysicsLayer()
  return self.hitPhysicsLayer
end

function TileData:setHitBoxCollidesWithLayerExplicit(value)
  self.hitCollidesWithLayer = value
end

function TileData:setHurtBoxCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.hitCollidesWithLayer = bit.bor(self.hitCollidesWithLayer, BitTag.get(v).value)
    end
  else
    self.hitCollidesWithLayer = bit.bor(self.hitCollidesWithLayer, BitTag.get(layer).value)
  end
end

function TileData:unsetHurtBoxCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.hitCollidesWithLayer = bit.band(self.hitCollidesWithLayer, bit.bnot(BitTag.get(v).value))
    end
  else
    self.hitCollidesWithLayer = bit.band(self.hitCollidesWithLayer, bit.bnot(BitTag.get(layer).value))
  end
end

function TileData:setHitBoxPhysicsLayerExplicit(value)
  self.hitPhysicsLayer = value
end

function TileData:setHitBoxPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.hitPhysicsLayer = bit.bor(self.hitPhysicsLayer, BitTag.get(v).value)
    end
  else
    self.hitPhysicsLayer = bit.bor(self.hitPhysicsLayer, BitTag.get(layer).value)
  end
end

function TileData:unsetHitBoxPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.hitPhysicsLayer = bit.band(self.hitPhysicsLayer, bit.bnot(BitTag.get(v).value))
    end
  else
    self.hitPhysicsLayer = bit.band(self.hitPhysicsLayer, bit.bnot(BitTag.get(layer).value))
  end
end

-- Templates
function TileData.addTemplate(name, tileData)
  assert(not Templates[name], 'Tile Template with name ' .. name .. ' already exists')
  Templates[name] = tileData
end

function TileData.createFromTemplate(name)
  assert(Templates[name], 'Tile Template with name ' .. name .. ' does not exist')
  return Templates[name]:clone()
end

function TileData.initializeTemplates(path)
  path = path or 'data.tile_templates'
  require(path)(TileData)
end

return TileData