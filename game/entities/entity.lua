local Class = require 'lib.class'
local Transform = require 'lib.transform'
local Vector = require 'lib.vector'
local ComponentList = require 'game.entities.component_list'

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

    self.componentList = ComponentList(self)
    self.enabled = enabled
    self.visible = visible
    self.transform = Transform.new()
    self.transform:setPosition(x, y)
    
    -- bump box variables
    self.x, self.y = rect.x - rect.w / 2, rect.y - rect.h / 2
    self.w, self.h = rect.w, rect.h
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

--transform passthroughs
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
  self.x = x - self.w / 2
  self.y = y - self.h / 2
  self.transform:setPosition(x, y)
end

function Entity:setPositionWithBumpCoords(x, y)
  self.x = x
  self.y = y
  self.transform:setPosition(x + self.w / 2, y + self.h / 2)
end

function Entity:setLocalPosition(x, y)
  self.transform:setLocalPosition(x, y)
end

-- gameloop callbacks
function Entity:update(dt)
  self.componentList:update(dt)
end

function Entity:draw()
  self.componentList:draw()
end

function Entity:debugDraw()
  --love draws from the upper left corner so we use our bump coordinates
  local positionX, positionY = self:getBumpPosition()
  love.graphics.setColor(0, 0, 225 / 225)
  --love.graphics.setColor(0, 1, 0)
  love.graphics.rectangle("fill", positionX, positionY, self.w, self.h)
  self.componentList:debugDraw()
end

return Entity