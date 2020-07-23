local Class = require 'lib.class'
local TestEntity = require 'game.test_player'

local EntityTest = Class {
  init = function(self)
    self.testEntity = nil
    self.effect = nil
  end
}

function EntityTest:enter(previous, ...)
  self.testEntity = TestEntity()
end

function EntityTest:update(dt)
  self.testEntity:update(dt)
end

function EntityTest:draw()
  self.testEntity:draw()
  self.testEntity:debugDraw() 
end

return EntityTest