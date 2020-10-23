local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local BumpBox = require 'engine.entities.bump_box'
local Transform = require 'engine.entities.transform'
local Vector = require 'lib.vector'
local ComponentList = require 'engine.entities.component_list'
local rect = require 'engine.utils.rectangle'

local Entity = Class { __includes = { SignalObject, BumpBox },
  init = function(self, enabled, visible, rect, zRange)
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
    BumpBox.init(self, rect.x - rect.w / 2, rect.y - rect.h / 2, rect.w, rect.h, zRange)
    self.componentList = ComponentList(self)
    self.enabled = enabled
    self.visible = visible
    self.transform = Transform:new(self)
    self:setPositionWithBumpCoords(self.x, self.y)
  end
}

function Entity:getType()
  return 'entity'
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
  self.x = ex - self.w / 2
  self.y = ey - self.h / 2
  self.componentList:transformChanged()
end

function Entity:getLocalPosition()
  local x, y, z = self.transform:getLocalPosition()
  return x, y
end

function Entity:getZPosition()
  local x, y, z= self.transform:getLocalPosition()
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

function Entity:setPosition(x, y)
  self.transform:setPosition(x, y)
end

function Entity:setPositionWithBumpCoords(x, y)
  self.transform:setPosition(x + self.w / 2, y + self.h / 2)
end
function Entity:setLocalPosition(x, y)
  self.transform:setLocalPosition(x, y)
end

function Entity:resize(width, height)
  physics.remove(self)
  self.x, self.y, self.w, self.h = rect.resizeAroundCenter(self.x, self.y, self.w, self.h, width, height)
  physics.add(self)
end

-- component list stuff
function Entity:add(component)
  self.componentList:add(component)
end

function Entity:remove(component)
  self.componentList:remove(component)
end

function Entity:updateComponents(dt)
  self.componentList:update(dt)
end

function Entity:drawComponents()
  self.componentList:draw()
end

function Entity:debugDrawComponents()
  self.componentList:debugDraw()
end

-- gameloop callbacks
function Entity:awake()
  physics.add(self)
  self.componentList:entityAwake()
  if self.onAwake ~= nil then
    self:onAwake()
  end
end

function Entity:update(dt)
  self:updateComponents(dt)
end

function Entity:draw()
  self:drawComponents()
end

function Entity:removed(scene)
  physics.remove(self)
  self.componentList:entityRemoved(scene)
  self.scene = nil
  if self.onRemoved ~= nil then
    self:onRemoved(scene)
  end
end

function Entity:debugDraw()
  self:debugDrawComponents()
  
  --love draws from the upper left corner so we use our bump coordinates
  local positionX, positionY = self:getBumpPosition()
  love.graphics.setColor(0, 0, 160 / 225, 180 / 255)
  love.graphics.rectangle("fill", positionX, positionY, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

return Entity