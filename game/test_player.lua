local Class = require 'lib.class'
local Transform = require 'lib.transform'
local Vector2 = require 'lib.vector'

local TestPlayer = Class {
  init = function(self, x, y)
    if x == nil then x = 0 end
    if y == nil then y = 0 end
    self.x = x
    self.y = y
  end
}

function TestPlayer:update(dt)
  local inputX, inputY = 0, 0
  if love.keyboard.isDown("w") then
    inputY = -1
  end
  if love.keyboard.isDown("s") then
    inputY = 1
  end
  if love.keyboard.isDown("a") then
    inputX = -1 
  end
  if love.keyboard.isDown("d") then
    inputX = 1
  end
    
  self.x = self.x + ( inputX * 60 * dt )
  self.y = self.y + ( inputY * 60 * dt )
end

function TestPlayer:draw()
  love.graphics.setColor(0 / 255, 128 / 255, 0 / 255)
  love.graphics.rectangle("fill", self.x, self.y, 16, 16)
end

return TestPlayer