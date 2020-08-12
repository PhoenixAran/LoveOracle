local Class = require 'lib.class'
local TestEntity = require 'engine.test_game_entity'

local GameEntityTest = Class {
  init = function(self)
    self.testEntity = nil
    self.effect = nil
    self.testBoxes = { }
  end
}

function GameEntityTest:addTestBox(x, y, w, h)
  local box = { x = x, y = y, w = w, h = h }
  self.testBoxes[#self.testBoxes + 1] = box
  bumpWorld:add(box, x, y, w, h)
end

function GameEntityTest:drawTestBoxes()
  for _, box in ipairs(self.testBoxes) do
    love.graphics.setColor(255 / 255, 0, 0, 70 / 255)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(255 / 255, 0, 0)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
  end
end

function GameEntityTest:enter(previous, ...)
  self.testEntity = TestEntity()
  self:addTestBox(20, 20, 16, 16)
  self:addTestBox(50, 50, 30, 24)
  self:addTestBox(45, 23, 15, 23)
  self.testEntity:awake()
end

function GameEntityTest:update(dt)
  self.testEntity:update(dt)
end

function GameEntityTest:draw()
  self.testEntity:draw()
  self.testEntity:debugDraw() 
  self:drawTestBoxes()
end

return GameEntityTest