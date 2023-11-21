local Class = require 'lib.class'
local DisplayHandler = require 'engine.display_handler'

local HelloWorldTest = Class {
  init = function(self)
    self.testEntity = nil
  end
}

function HelloWorldTest:update(dt)
end

function HelloWorldTest:draw()
  DisplayHandler.push()
  love.graphics.print("Hello World!", 24, 24)
  DisplayHandler.pop()
end

return HelloWorldTest