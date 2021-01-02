local Class = require 'lib.class'
local Vector = require 'lib.vector'
local MapEntity = require 'engine.entities.map_entity'

local TestPlayer = Class { __includes = MapEntity,
  init = function(self)
    MapEntity.init(self, 'test_player', true, true, {x = 70, y = 70, h = 16, w = 16})
  end
}

function TestPlayer:update(dt)
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