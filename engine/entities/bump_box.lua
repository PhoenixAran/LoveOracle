local Class = require 'lib.class'
local bit = require 'bit'
local rect = require 'engine.math.rectangle'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'

--- ZRange
---@class ZRange
---@field min integer
---@field max integer
local __ZRange = { }

---Basis for all physics based classes
---@class BumpBox
---@field zRange ZRange
---@field x number
---@field y number
---@field w integer
---@field h integer
---@field z number
---@field collidesWithLayer number layers this bumpbox should collide with
---@field physicsLayer number layer this bumpbox exists in
---@field registeredWithPhysics boolean flag to keep track if this bumpbox
---@field registeredPhysicsBounds table the bounds of this box when it was registered with the physics system
---@field init function given from class module. Here so language server doesnt complain init does not exist
local BumpBox = Class {
  init = function(self, args)
    if args == nil then
      args = { }
    end
    if args.x == nil then args.x = 0 end
    if args.y == nil then args.y = 0 end
    if args.w == nil then args.w = 1 end
    if args.h == nil then args.h = 1 end
    if args.z == nil then args.z = 0 end
    if args.zMin == nil then args.zMin = 0 end
    if args.zMax == nil then args.zMax = 1 end

    assert(args.zMin <= args.zMax)
    self.zRange = { min = args.zMin, max = args.zMax }
    self.x = args.x
    self.y = args.y
    self.w = args.w
    self.h = args.h
    self.z = args.z

    self.collidesWithLayer = 0
    self.physicsLayer = 0

    self.registeredWithPhysics = false
    -- the bounds of this box when it was registered with they physics system
    -- storing this allows us to always be able to safely remove the box even if it was moved
    -- before attempting to remove it
    self.registeredPhysicsBounds = { x = 0, y = 0, w = 0, h = 0 }
  end
}

function BumpBox:getType()
  return 'bump_box'
end

---Returns min and max zrange values this bumpbox can collide with
---@return integer min zrange level
---@return integer max zrange level
function BumpBox:getZRange()
  return self.zRange.min, self.zRange.max
end

--- set z range bumpbox can collide with
---@param min number
---@param max number
function BumpBox:setZRange(min, max)
  assert(min <= max)
  self.zRange.min = min
  self.zRange.max = max
end

---set min z range value
---@param value number
function BumpBox:setMinZRange(value)
  self.zRange.min = value
end

---set max zrange value
---@param value number
function BumpBox:setMaxZRange(value)
  self.zRange.max = value
end

---optional additional callback for physics system to use when determining
--- if this bumpbox should collide with another bumpbox
---@param otherBox BumpBox
---@return boolean
function BumpBox:additionalPhysicsFilter(otherBox)
  return true
end

---gets the position this bumpbox is in from the top left corner
---@return number
---@return number
function BumpBox:getBumpPosition()
  return self.x, self.y
end

---returns the bounds of this bumpbox
---@return number x
---@return number y
---@return integer w
---@return integer h
function BumpBox:getBounds()
  return self.x, self.y, self.w, self.h
end

---returns the width and height of this bumpbox
---@return integer
---@return integer
function BumpBox:getSize()
  return self.w, self.h
end

-- returns the layers this bumpbox collides with
---@return integer collidesWithLayer
function BumpBox:getCollidesWithLayer()
  return self.collidesWithLayer
end

---return the physics layer this bumpbox exists integer
---@return integer physicsLayer
function BumpBox:getPhysicsLayer()
  return self.physicsLayer
end

---explicitely set colliedsWithLayer with a bit integer
function BumpBox:setCollidesWithLayerExplicit(value)
  self.collidesWithLayer = value
end

---Sets what layers the bumpbox collides with
---@param layer string|string[] bit layer(s)
function BumpBox:setCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.collidesWithLayer = bit.bor(self.collidesWithLayer, PhysicsFlags:get(v).value)
    end
  else
    self.collidesWithLayer = bit.bor(self.collidesWithLayer, PhysicsFlags:get(layer).value)
  end
end

---Unsets what layers the bumpbox collides with
---@param layer string|string[] bit layer(s)
function BumpBox:unsetCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.collidesWithLayer = bit.band(self.collidesWithLayer, bit.bnot(PhysicsFlags:get(v).value))
    end
  else
    self.collidesWithLayer = bit.band(self.collidesWithLayer, bit.bnot(PhysicsFlags:get(layer).value))
  end
end

---set physics layer with an explicit bit value
---@param value number
function BumpBox:setPhysicsLayerExplicit(value)
  self.physicsLayer = value
end

---Sets what layers this bumpbox exists in
---@param layer string|string[] bit layer(s)
function BumpBox:setPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.bor(self.physicsLayer, PhysicsFlags:get(v).value)
    end
  else
    self.physicsLayer = bit.bor(self.physicsLayer, PhysicsFlags:get(layer).value)
  end
end

---Unsets what layer this bumpbox exists in
---@param layer string|string[] bit layer(s)
function BumpBox:unsetPhysicsLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(PhysicsFlags:get(v).value))
    end
  else
    self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(PhysicsFlags:get(layer).value))
  end
end

--- check if the other bumpbox's physicsLayer matches this bumpbox's collidesWithLayer
---@param otherBumpBox BumpBox
---@return boolean
function BumpBox:reportsCollisionsWith(otherBumpBox)
  local otherPhysicsLayer = otherBumpBox:getPhysicsLayer()
  if bit.band(otherPhysicsLayer, self.collidesWithLayer) ~= 0 then
    return self:additionalPhysicsFilter(otherBumpBox)
  end
  return false
end

--helper function that determines if a bumpbox can collide with another bumpbox (see bump module)
---@param item BumpBox
---@param other BumpBox
---@return boolean
BumpBox.canCollide = function(item, other)
  return bit.band(other.physicsLayer, item.collidesWithLayer) ~= 0
         and other.zRange.max >= item.zRange.min and other.zRange.min <= item.zRange.max
end

return BumpBox