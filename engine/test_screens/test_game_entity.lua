local Class = require 'lib.class'
local Vector = require 'engine.math.vector'
local MapEntity = require 'engine.entities.map_entity'
local input = require('engine.singletons').input

---@class TestPlayer : MapEntity
local TestPlayer = Class { __includes = MapEntity,
  init = function(self)
    MapEntity.init(self, {name = 'test_player',x = 70, y = 70, h = 16, w = 16})
  end
}

function TestPlayer:update(dt)
  local inputX, inputY = input:get('move')
  self:setVector(inputX, inputY)
  self:move(dt)
end

return TestPlayer