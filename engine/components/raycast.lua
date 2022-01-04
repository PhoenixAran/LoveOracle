local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local Component = require 'engine.entities.component'
local Physics = require 'engine.physics'
local BitTag = require 'engine.utils.bit_tag'

local Raycast = Class { __includes = { Component },
  init = function(self, entity, enabled)
    Component.init(self, entity, enabled)
    self.offsetX = 0
    self.offsetY = 0 
    self.castToX = 0
    self.castToY = 0
    self.zRange = {
      min = -100,
      max = 100
    }
    self.exceptions = { }

    -- layer this raycast should detect
    self.collidesWithLayer = 0
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

function Raycast:setCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do 
      self.collidesWithLayer = bit.bor(self.collidesWithLayer, BitTag.get(v).value)
    end
  else
    self.collidesWithLayer = bit.bor(self.collidesWithLayer, BitTag.get(layer).value)
  end
end

function Raycast:unsetCollidesWithLayer(layer)
  if type(layer) == 'table' then
    for _, v in ipairs(layer) do
      self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(BitTag.get(v).value))
    end
  else
    self.physicsLayer = bit.band(self.physicsLayer, bit.bnot(BitTag.get(layer).value))
  end
end

function Raycast:setCollidesWithLayerExplicit(value)
  self.collidesWithLayer = value
end

function Raycast:addException(box)
  lume.push(self.exceptions, box)
end

function Raycast:removeException(box)
  lume.push(self.exceptions, box)
end

function Raycast:linecast()
  -- TODO
end

function Raycast:debugDraw()
  -- TODO
end

return Raycast