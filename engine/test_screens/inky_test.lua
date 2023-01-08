local Class = require 'lib.class'
local Inky = require 'lib.inky'
local flux = require 'engine.ui.flux'

-- example button
local button = Inky.defineElement(function(self)
  self.props.count = 0
  
  self:onPointer('release', function()
    self.props.count = self.props.count + 1
  end)

  return function(_, x, y, w, h)
		love.graphics.rectangle("line", x, y, w, h)
		love.graphics.printf("I have been clicked " .. self.props.count .. " times", x, y, w, "center")
  end
end)

-- screen
local InkyTest = Class {
  init = function(self)
    self.scene = Inky.scene()
    self.pointer = Inky.pointer(self.scene)
    self.button = button(self.scene)
  end
}

function InkyTest:enter(previous, ...)
end

function InkyTest:leave(next, ...)
end

function InkyTest:update(dt)
  self.pointer:setPosition(love.mouse.getPosition())
end

function InkyTest:draw()
  self.scene:beginFrame()
  self.button:render(10, 10, 200, 16)
  self.scene:finishFrame()
end

function InkyTest:resize(x, y)
  self.scene:resize(x, y)
end

function InkyTest:mousereleased(x, y, button)
  if button == 1 then
    self.pointer:raise('release')
  end
end

return InkyTest