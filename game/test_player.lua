local Class = require 'lib.class'
local Vector = require 'lib.vector'
local Entity = require 'game.entities.entity'

local TestPlayer = Class { __includes = Entity,
  init = function(self)
    Entity.init(self, true, true, {x = 0, y = 0, h = 16, w = 16})
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
  
  if love.keyboard.isDown("p") then
    print('transform position: ' .. self:getPosition())
    print('bump position: ' .. self:getBumpPosition())
  end
  
  
  local x, y = self:getPosition()
  local velX, velY = Vector.mul(dt * 60, Vector.normalize(inputX, inputY))
  self:setPosition(x + velX, y + velY)
end

return TestPlayer