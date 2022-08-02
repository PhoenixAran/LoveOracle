local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local bit = require 'bit'
local Component = require 'engine.entities.component'
local Physics = require 'engine.physics'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'

---@class Raycast : Component
---@field offsetX number
---@field offsetY number
---@field castToX number
---@field castToY number
---@field zRange ZRange
---@field exceptions BumpBox[]
---@field collidesWithLayer integer
---@field collidesWithTileLayer integer
---@field hits any[]
---@field filter function
local Raycast = Class { __includes = { Component },
  init = function(self, entity, args)
    Component.init(self, entity, args)
    if args == nil then
      args = { }
    end
    self.offsetX = args.offsetX or 0
    self.offsetY = args.offsetY or 0
    self.castToX = args.castToX or 0
    self.castToY = args.castToY or 0
    self.zRange = {
      min = -100,
      max = 100
    }
    self.exceptions = { }
    self.hits = { } 
    -- layer this raycast should detect
    self.collidesWithLayer = 0
    -- tiletypes this raycast should detect
    self.collidesWithTileLayer = 0

    local raycastInstance = self
    self.filter = function(item)
      if bit.band(item.physicsLayer, raycastInstance.collidesWithLayer) ~= 0 and item.zRange.max > raycastInstance.zRange.min
      and item.zRange.min < item.zRange.max then
        if item.isTile and item:isTile() then
          if bit.band(raycastInstance.collidesWithTileLayer, item.tileData.tileType) ~= 0 then
            return true
          end
          return false
        end
        return true
      end
      return false
    end
  end
}

function Raycast:getType()
  return 'raycast'
end

function Raycast:getZRange()
  return self.zRange.min, self.zRange.max
end

function Raycast:setZRange(min, max)
  self.zRange.min = min
  self.zRange.max = max
end


function Raycast:getCollisionLayer()
  return self.collidesWithLayer
end

---@param layer string|string[]
function Raycast:setCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do 
      self.collidesWithLayer = bit.bor(self.collidesWithLayer, PhysicsFlags:get(v).value)
    end
  else
    self.collidesWithLayer = bit.bor(self.collidesWithLayer, PhysicsFlags:get(layer).value)
  end
end

---@param layer string|string[]
function Raycast:unsetCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(PhysicsFlags:get(v).value))
    end
  else
    self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(PhysicsFlags:get(layer).value))
  end
end

---@param value integer
function Raycast:setCollidesWithLayerExplicit(value)
  self.collidesWithLayer = value
end

---@param tileType string|string[]
function Raycast:setCollisionTile(tileType)
  if type(tileType) == 'table' then
    for _, v in ipairs(tileType) do
      self.collidesWithTileLayer = bit.band(self.collidesWithTileLayer, bit.bnot(TileTypeFlags:get(v).value))
    end
  else
    self.collidesWithTileLayer = bit.band(self.collidesWithTileLayer, bit.bnot(TileTypeFlags:get(tileType).value))
  end
end

---@param tileType string|string[]
function Raycast:unsetCollisionTile(tileType)
  if (tileType) == 'table' then
    for _, v in ipairs(tileType) do
      self.collidesWithTileLayer = bit.band(self.collidesWithTileLayer, bit.bnot(TileTypeFlags:get(v).value))
    end
  else
    self.collidesWithTileLayer = bit.band(self.collidesWithTileLayer, bit.bnot(TileTypeFlags:get(tileType).value))
  end
end

---@param value integer
function Raycast:setCollisionTileExplicit(value)
  self.collidesWithTileLayer = value
end

---@param x number
---@param y number
function Raycast:setOffset(x, y)
  self.offsetX = x
  self.offsetY = y
end

---@param x number
---@param y number
function Raycast:setCastTo(x, y)
  self.castToX = x
  self.castToY = y
end

---@param box BumpBox
function Raycast:addException(box)
  lume.push(self.exceptions, box)
end

---@param box BumpBox
function Raycast:removeException(box)
  lume.push(self.exceptions, box)
end

---@return boolean collisionsExisted
function Raycast:linecast()
  lume.clear(self.hits)
  local ex, ey = self.entity:getPosition()
  local x1, y1 = vector.add(ex, ey, self.offsetX, self.offsetY)
  local x2, y2 = vector.add(x1, y1, self.castToX, self.castToY)
  local items, len = Physics:querySegment(x1, y1, x2, y2, self.filter)
  for _, item in ipairs(items) do
    lume.push(self.hits, item)
  end
  Physics.freeTable(items)

  return len > 0
end

function Raycast:debugDraw()
  local arrowLength = 10
  local arrowLineAngle = math.pi / 6
  local ex, ey = self.entity:getPosition()
  local x1, y1 = ex + self.offsetX, ey + self.offsetY
  local x2, y2 = x1 + self.castToX, y1 + self.castToY
  love.graphics.setColor(.52, 0, .80)
  love.graphics.line(x1, y1, x2, y2)
  --local a = math.atan2(y1 - y2, x1 - x2)
  --love.graphics.line(x2, y2, x2 + arrowLength * math.cos(a + arrowLineAngle),
  --                   y2 + arrowLineAngle + arrowLength * math.sin(a + arrowLineAngle))
  --love.graphics.line(x2, y2, x2 + arrowLength * math.cos(a - arrowLineAngle),
  --                   y2 + arrowLineAngle + arrowLength * math.sin(a - arrowLineAngle))
  love.graphics.setColor(.88, 0, .2)
  love.graphics.rectangle('fill', x2 - .5, y2 - .5, 1, 1)
  love.graphics.setColor(0, 0, 0)
end

return Raycast