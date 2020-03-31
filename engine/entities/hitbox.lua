local class = require 'lib.class'
local Transform = require 'lib.transform'
local Component = require 'engine.entities.component'

local Hitbox = class {
  __includes = Component,
  init = function(self, w, h, bumpWorld)
    Component.init(self, true)
    self.x = 0
    self.y = 0
    self.w = w
    self.h = h
    self.bumpWorld = bumpWorld
    self.transform = Transform.new()
  end
}

function Hitbox:getType()
  return 'hitbox'
end

function Hitbox:getBumpPosition()
  return self.x, self.y
end

function Hitbox:setBumpWorld(bumpWorld)
  if self.bumpWorld and self.bumpWorld ~= bumpWorld then
    self.bumpWorld:remove(self)
  end
  self.bumpWorld = bumpWorld
end

function Hitbox:updateBumpPosition()
  local x, y = self:getPosition()
  self.x = x - self.w / 2
  self.y = y - self.h / 2
end

function Hitbox:setEntity(entity)
  Component.setEntity(self, entity)
  self.x, self.y = self:getPosition()
end

function Hitbox:bumpFilter(item, other)
  return 'cross'
end

function Hitbox:entityAwake()
  assert(self.bumpWorld ~= nil, "Hitbox component expects a bump world instance when awoken")
  self:updateBumpPosition() --update bump position if parent transform moved
  self.bumpWorld:add(self, self.x, self.y, self.w, self.h)
end

function Hitbox:update(dt)
  self:updateBumpPosition()
  self.bumpWorld:update(self, self.x, self.y, self.w, self.h)
end

function Hitbox:debugDraw()
  love.graphics.setColor(1, 0, 0, .3)
  love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
end

return Hitbox
