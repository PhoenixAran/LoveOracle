local class = require 'lib.class'
local bump = require 'lib.bump'
local Vector2 = require 'lib.vec2'
local Scene = require 'engine.scene'
local Entity = require 'engine.entities.entity'


local EntityMoveTest = class {
  __includes = Scene,
  init = function(self)
    self.entity = nil
    self.world = bump.newWorld(32)
    self.staticBoxes = { }
  end
}

function EntityMoveTest:addStaticBox(x, y, w, h)
  local block = { x = x, y = y, w = w, h = h }
  self.staticBoxes[#self.staticBoxes + 1] = block
  function block:getType()
    return 'tile'
  end
  self.world:add(block, x, y, w, h)
end

function EntityMoveTest:drawStaticBoxes()
  for _, box in ipairs(self.staticBoxes) do
    love.graphics.setColor(255 / 255, 0, 0, 70 / 255)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(255 / 255, 0, 0)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
  end
end

function EntityMoveTest:load()
  self.entity = Entity(20, 20, 16, 16, self.world)
  self:addStaticBox(30, 30, 16, 16)
  self:addStaticBox(50, 50, 30, 24)
  self.entity:awake()
end

function EntityMoveTest:update(dt)
  local xInput, yInput = 0, 0
  if Input:down('up') then
    yInput = -1
  elseif Input:down('down') then
    yInput = 1
  end

  if Input:down('left') then
    xInput = -1
  elseif Input:down('right') then
    xInput = 1
  end

  self.entity:setVector(xInput, yInput)
  self.entity:move(self.entity:getLinearVelocity(dt))
end

function EntityMoveTest:draw()
  self:drawStaticBoxes()
  self.entity:debugDraw()
end

return EntityMoveTest
