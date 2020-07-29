local Class = require 'lib.class'
local Transform = require 'engine.entities.transform'
local Vector = require 'lib.vector'
local ComponentList = require 'engine.entities.component_list'

local Entity = Class { 
  init = function(self, enabled, visible, rect)
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
    
    self.x = rect.x - rect.w / 2
    self.y = rect.y - rect.h / 2
    self.w = rect.w
    self.h = rect.h    
    self.collidesWithLayers = { }
    self.physicsLayer = { }
    
    self.componentList = ComponentList(self)
    self.enabled = enabled
    self.visible = visible
    self.transform = Transform:new(self)
    self:setPositionWithBumpCoords(self.x, self.y)
  end
}

function Entity:getType()
  return "entity"
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

function Entity:getPosition()
  local x, y, z = self.transform:getPosition()
  return x, y
end

function Entity:getBumpPosition()
  return self.x, self.y
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

-- component list stuff
function Entity:add(component)
  self.componentList:add(component)
end

function Entity:remove(component)
  self.componentList:remove(component)
end

-- gameloop callbacks
function Entity:awake()
  bumpWorld:add(self, self.x, self.y, self.w, self.h)
  self.componentList:entityAwake()
  if self.onAwake ~= nil then
    self:onAwake()
  end
end

function Entity:update(dt)
  self.componentList:update(dt)
end

function Entity:draw()
  self.componentList:draw()
end

function Entity:removed(scene)
  bumpWorld:remove(self)
  self.componentList:entityRemoved(scene)
  self.scene = nil
  if self.onRemoved ~= nil then
    self:onRemoved(scene)
  end
end

function Entity:debugDraw()
  self.componentList:debugDraw()
  
  --love draws from the upper left corner so we use our bump coordinates
  local positionX, positionY = self:getBumpPosition()
  love.graphics.setColor(0, 0, 160 / 225, 180 / 255)
  love.graphics.rectangle("fill", positionX, positionY, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
end

return Entity