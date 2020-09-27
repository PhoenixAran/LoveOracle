local Class = require 'lib.class'
local rect = require 'engine.utils.rectangle'


local BumpBox = Class {
  init = function(self, x, y, w, h, collisionTag)
    if x == nil then x = 0 end
    if y == nil then y = 0 end
    if w == nil then w = 1 end
    if h == nil then h = 1 end
    if collisionTag == nil then collisionTag = 'bumpbox' end
      
    self.x = x
    self.y = y
    self.w = w
    self.h = h
    
    -- layers this bumpbox should collide with
    self.collidesWithLayer = { }
    -- layers this bumpbox exists in
    self.physicsLayer = { }
    -- the bounds of this box when it was registered with they physics system
    -- storing this allows us to always be able to safely remove the box even if it was moved
    -- before attempting to remove it
    self.registeredPhysicsBounds = { x = 0, y = 0, w = 0, h = 0 }
  end
}

function BumpBox:getType()
  return 'bumpbox'
end

function BumpBox:getCollisionTag()
  return 'bumpbox'
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

-- layer stuff
function BumpBox:getCollidesWithLayer()
  return self.collidesWithLayer
end

function BumpBox:getPhysicsLayer()
  return self.physicsLayer
end

function BumpBox:setCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in pairs(layer) do
      self.collidesWithLayer[v] = true
    end
  else
    self.collidesWithLayer[layer] = true
  end
end

function BumpBox:unsetCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in pairs(layer) do
      self.collidesWithLayer[layer] = nil
    end
  else
    self.collidesWithLayer[layer] = nil
  end
end

function BumpBox:setPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in pairs(layer) do
      self.physicsLayer[v] = true
    end
  else
    self.physicsLayer[layer] = true
  end
end

function BumpBox:unsetPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in pairs(layer) do
      self.physicsLayer[layer] = nil
    end
  else
    self.physicsLayer[layer] = nil
  end
end

-- check if the other bumpbox's physicsLayer matches 
-- this bumpbox's collidesWithLayer
function BumpBox:reportsCollisionsWith(otherBumpBox)
  for k, v in pairs(otherBumpBox:getPhysicsLayer()) do
    if self.collidesWithLayer[k] then 
      return self.additionalPhysicsFilter(otherBumpBox)
    end
  end
  return false
end

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