local Class = require 'lib.class'
local Vector = require 'lib.vector'
local GameEntity = require 'engine.entities.game_entity'

local TestPlayer = Class { __includes = GameEntity,
  init = function(self)
    GameEntity.init(self, true, true, {x = 0, y = 0, h = 16, w = 16})
  end
}

function TestPlayer:update(dt)
  GameEntity.update(self, dt)
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
  self:setVector(inputX, inputY)
  self:move(dt)
end

return TestPlayer