local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local TablePool = require 'engine.utils.table_pool'
local MapEntity = require 'engine.entities.map_entity'
local Physics = require 'engine.physics'
local Collider = require 'engine.components.collider'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local BitTag = require 'engine.utils.bit_tag'

local Enemy = Class { __includes = MapEntity,
  init = function(self, args)
    MapEntity.init(self, args)
  end
}

function Enemy:getType()
  return 'enemy'
end

function Enemy:getCollisionTag()
  return 'enemy'
end

-- some utility functions for enemy scripts
function Enemy:canMoveInDirection(x, y)
  -- check for any tiles in the way
  local tileTag = BitTag.get('tile')
  
  -- check for anything the entity can collide with is in the way

end


return Enemy