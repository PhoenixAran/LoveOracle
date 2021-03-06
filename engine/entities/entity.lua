local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local BumpBox = require 'engine.entities.bump_box'
local Transform = require 'engine.entities.transform'
local Vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local InspectorProperties = require 'engine.entities.inspector_properties'

local Physics = require 'engine.physics'

local Entity = Class { __includes = { SignalObject, BumpBox },
  init = function(self, name, enabled, visible, rect, zRange)
    SignalObject.init(self)
    if enabled == nil then enabled = true end
    if visible == nil then visible = true end
    if rect == nil then
      rect = { 
        x = 0, 
        y = 0, 
        w = 1, 
        h = 1
      }
    else
      if rect.x == nil then rect.x = 0 end
      if rect.y == nil then rect.y = 0 end
      if rect.w == nil then rect.w = 1 end
      if rect.h == nil then rect.h = 1 end
    end
    if rect.useBumpCoords then
      BumpBox.init(self, rect.x, rect.y, rect.w, rect.h, zRange)
    else
      BumpBox.init(self, rect.x - rect.w / 2, rect.y - rect.h / 2, rect.w, rect.h, zRange)
    end
    self.enabled = enabled
    self.visible = visible
    
    -- KEEP THESE TWO TOGETHER OR ELSE ENTITY POSITION GETS MESSED UP
    self.transform = Transform:new(self)
    self:setPositionWithBumpCoords(self.x, self.y)
  
    self.transform:setRotation(0)
    
    self.name = name
  end
}

function Entity:getName()
  return self.name
end

function Entity:getType()
  return 'entity'
end

function Entity:isTile()
  return false
end

function Entity:getCollisionTag()
  return 'entity'
end

function Entity:setVisible(value)
  self.visible = value
end

function Entity:isVisible()
  return self.visible
end

function Entity:setEnabled(value)
  self.enabled = value
end

function Entity:isEnabled()
  return self.enabled
end

-- position and transform stuff
function Entity:transformChanged()
  local ex, ey = self:getPosition()
  -- need to manually calculate it because Entity:setPositionWithBumpCoords
  -- will trigger transform:change which will cause in infinite loop
  self.x = ex - self.w / 2
  self.y = ey - self.h / 2
  if self.onTransformChanged then
    self:onTransformChanged()
  end
end

function Entity:getLocalPosition()
  local x, y, z = self.transform:getLocalPosition()
  return x, y
end

function Entity:getZPosition()
  local x, y, z = self.transform:getPosition()
  return z
end

function Entity:setZPosition(z)
  local x, y = self:getPosition()
  self.transform:setPosition(x, y, z)
end

function Entity:getPosition()
  local x, y, z = self.transform:getPosition()
  return x, y
end

function Entity:setPosition(x, y, z)
  if z == nil then z = self:getZPosition() end
  self.transform:setPosition(x, y, z)
end

function Entity:setPositionWithBumpCoords(x, y)
  self.transform:setPosition(x + self.w / 2, y + self.h / 2)
end

function Entity:setLocalPosition(x, y)
  self.transform:setLocalPosition(x, y)
end

function Entity:resize(width, height)
  Physics.remove(self)
  self.x, self.y, self.w, self.h = rect.resizeAroundCenter(self.x, self.y, self.w, self.h, width, height)
  Physics.add(self)
end

function Entity:addChild(entity)
  entity.transform:setParent(self.transform)
end

-- gameloop callbacks
function Entity:added(gameScreen)
  
end

function Entity:awake()
  Physics.add(self)
  if self.onAwake then
    self:onAwake()
  end
end

function Entity:update(dt)
  
end

function Entity:draw()

end

function Entity:removed(scene)
  Physics.remove(self)
  self.scene = nil
  if self.onRemoved then
    self:onRemoved(scene)
  end
end

function Entity:debugDraw()
  --love draws from the upper left corner so we use our bump coordinates
  local positionX, positionY = self:getBumpPosition()
  love.graphics.setColor(0, 0, 160 / 225, 180 / 255)
  love.graphics.rectangle('fill', positionX, positionY, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

function Entity:getInspectorProperties()
  local props = InspectorProperties(self)
  props:addReadOnlyString('Name', 'name')
  props:addVector2('Position', self.getPosition, self.setPosition)
  props:addVector2i('Size', self.getSize, self.resize)
  return props
end

return Entity