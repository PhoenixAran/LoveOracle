local Class = require 'lib.class'

local HelloWorldTest = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function HelloWorldTest:update(dt)
end

function HelloWorldTest:draw()
  love.graphics.print("Hello World!", 24, 24)
end

return HelloWorldTest