local Class = require 'lib.class'
local Transform = require 'lib.transform'
local Vector2 = require 'lib.vector'
local Entity = require 'game.entities.entity'

local TestPlayer = Class { __includes = Entity,
  init = function(self)
    Entity.init(self, true, true, {x = 24, y = 24, h = 16, w = 16})
  end
}

function TestPlayer:update(dt)
  Entity.update(self)
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
  
  local x, y = self:getPosition()
  x = x + ( inputX * 60 * dt )
  y = y + ( inputY * 60 * dt )
  self:setPosition(x, y)  
end

return TestPlayer