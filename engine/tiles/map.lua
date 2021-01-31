local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'

local Map = Class { __includes = SignalObject,
  init = function(self, mapData)
    SignalObject.init(self)
    self.mapData = mapData
  end
}

return Map