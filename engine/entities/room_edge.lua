local Class = require 'lib.class'
local Entity = require 'engine.entities'
local vector = require 'lib.vector'
local lume = require 'lib.lume'

local RoomEdge = Class { __includes = Entity,
  init = function(self, enabled, rect, direction)
    Entity.init(self)
  end

}



return RoomEdge