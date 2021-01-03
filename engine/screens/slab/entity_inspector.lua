local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'

local EntityInspector = Class { __includes = SignalObject,
  init = function(self, entities)
    self.entities = { }
    self.entitiesHash = { }
    
    self.entitiesToAdd = { }
    self.entitiesToRemove = { }
  end
}