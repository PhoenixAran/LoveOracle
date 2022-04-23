local Class = require 'lib.class'
local monocle = require('engine.singletons').monocle

local HelloWorldTest = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function HelloWorldTest:update(dt)
end

function HelloWorldTest:draw()
  monocle:begin()
  love.graphics.print("Hello World!", 24, 24)
  monocle:finish()
end

return HelloWorldTest