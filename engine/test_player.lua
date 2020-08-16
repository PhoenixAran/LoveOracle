local Class = require 'lib.class'
local Vector = require 'lib.vector'
local Entity = require 'engine.entities.entity'

local TestPlayer = Class { __includes = Entity,
  init = function(self)
    Entity.init(self, true, true, {x = 0, y = 0, h = 16, w = 16})
  end
}

function TestPlayer:update(dt)
  Entity.update(self, dt)
  
  local inputX, inputY = 0, 0
  if input:down('left') then
    inputX = inputX - 1
  end
  if input:down('right') then
    inputX = inputX + 1
  end
  if input:down('up') then
    inputY = inputY - 1
  end
  if input:down('down') then
    inputY = inputY + 1
  end
  
  local x, y = self:getPosition()
  local velX, velY = Vector.mul(dt * 60, Vector.normalize(inputX, inputY))
  self:setPosition(x + velX, y + velY)
end

return TestPlayer