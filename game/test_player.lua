local Class = require 'lib.class'
local Vector = require 'lib.vector'
local Entity = require 'game.entities.entity'

local TestPlayer = Class { __includes = Entity,
  init = function(self)
    Entity.init(self, true, true, {x = 0, y = 0, h = 2, w = 2})
  end
}

function TestPlayer:update(dt)
  Entity.update(self)
  
  local inputX, inputY = input:get('move')
  local x, y = self:getPosition()
  local velX, velY = Vector.mul(dt * 60, Vector.normalize(inputX, inputY))
  self:setPosition(x + velX, y + velY)
end

return TestPlayer