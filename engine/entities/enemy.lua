local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local TablePool = require 'engine.utils.table_pool'
local MapEntity = require 'engine.entities.map_entity'

local Enemy = Class { __includes = MapEntity,
  init = function(self, data)
    MapEntity.init(self, data.name, data.enabled, data.visible, data.rect, data.zRange)
  end
}

function Enemy:getType()
  return 'enemy'
end

function Enemy:getCollisionTag()
  return 'enemy'
end

return Enemy