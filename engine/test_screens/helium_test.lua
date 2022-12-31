local Class = require 'lib.class'
local helium = require 'lib.helium'
local useState = require 'lib.helium.hooks.state'
local input = require 'lib.helium.core.input'

-- helium test elements
local elementCreator = helium(function(param, view)
  local elementState = useState({var = 10})
  return function()
    love.graphics.setColor(.3, .3, .3)
    love.graphics.rectangle('fill', 0, 0, view.w, view.h)
    elementState.var = elementState.var + 1
    love.graphics.setColor(1, 1, 1)
    love.graphics.print('elementState.var = ' .. tostring(elementState.var))
  end
end)

local elementCreatorWithInput = helium(function(param, view)
  local elementState = useState({down = false})
  input('clicked', function()
    elementState.down = not elementState.down
  end)
  return function()
    if elementState.down then
      love.graphics.setColor(1, 0, 0)
    else
      love.graphics.setColor(0, 1, 1)
    end
    love.graphics.print('button text')
  end
end)

-- screen
local HeliumTest = Class {
  init = function(self)
    self.scene = helium.scene.new(true)
    self.elem = elementCreator({text = 'hello world', var = 1}, 200, 400)
    self.elem:draw(100, 100)
    self.elemWithInput = elementCreatorWithInput(nil, 200, 200)
    self.elemWithInput:draw(200, 200)
  end
}

function HeliumTest:enter(previous, ...)
  self.scene:activate(true)
end

function HeliumTest:leave(netx, ...)
  self.scene:activate(false)
end

function HeliumTest:update(dt)
  self.scene:update(dt)
end

function HeliumTest:draw()
  self.scene:draw()
end

return HeliumTest