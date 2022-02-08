local Class = require 'lib.class'
local bit = require 'bit'
local rect = require 'engine.utils.rectangle'
local BitTag = require 'engine.utils.bit_tag'

local BumpBox = Class {
  init = function(self, x, y, w, h, zRange, collisionTag)
    if x == nil then x = 0 end
    if y == nil then y = 0 end
    if w == nil then w = 1 end
    if h == nil then h = 1 end
    if zRange == nil then
      zRange = {
        min = 0,
        max = 1
      }
    else
      if zRange.min == nil then zRange.min = 0 end
      if zRange.max == nil then zRange.max = 1 end
    end

    assert(zRange.min <= zRange.max)
    self.zRange = zRange
    if collisionTag == nil then collisionTag = 'bump_box' end
    self.x = x
    self.y = y
    self.w = w
    self.h = h

    -- layers this bumpbox should collide with
    self.collidesWithLayer = 0
    -- layers this bumpbox exists in
    self.physicsLayer = 0
    -- the bounds of this box when it was registered with they physics system
    -- storing this allows us to always be able to safely remove the box even if it was moved
    -- before attempting to remove it
    self.registeredPhysicsBounds = { x = 0, y = 0, w = 0, h = 0 }
  end
}

function BumpBox:getType()
  return 'bump_box'
end

function BumpBox:getCollisionTag()
  return self.collisionTag
end

function BumpBox:getZRange()
  return self.zRange.min, self.zRange.max
end

function BumpBox:setZRange(min, max)
  assert(min <= max)
  self.zRange.min = min
  self.zRange.max = max
end

function BumpBox:setMinZRange(value)
  self.zRange.min = value
end

function BumpBox:setMaxZRange(value)
  self.zRange.max = value
end

function BumpBox:additionalPhysicsFilter(otherBox)
  return true
end

function BumpBox:getBumpPosition()
  return self.x, self.y
end

function BumpBox:getBounds()
  return self.x, self.y, self.w, self.h
end

function BumpBox:getSize()
  return self.w, self.h
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

-- check if the other bumpbox's physicsLayer matches 
-- this bumpbox's collidesWithLayer
function BumpBox:reportsCollisionsWith(otherBumpBox)
  local otherPhysicsLayer = otherBumpBox:getPhysicsLayer()
  if bit.band(otherPhysicsLayer, self.collidesWithLayer) ~= 0 then
    return self:additionalPhysicsFilter(otherBumpBox)
  end
  return false
end

-- does not account for zrange. dont think it really should
function BumpBox:boxCast(otherBumpBox, motionX, motionY)
  if motionX == nil then motionX = 0 end
  if motionY == nil then motionY = 0 end
  local oldX, oldY = self:getBumpPosition()
  self.x = oldX + motionX
  self.y = oldY + motionY
  local didCollide, mtvx, mtvy, nx, ny = rect.boxToBox(self.x, self.y, self.w, self.h, otherBumpBox.x, otherBumpBox.y, otherBumpBox.w, otherBumpBox.h)
  self.x = oldX
  self.y = oldY
  return didCollide, mtvx, mtvy, nx, ny
end

return BumpBox