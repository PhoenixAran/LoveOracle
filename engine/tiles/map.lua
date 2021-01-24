local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalObject = require 'engine.signal_object'

local Map = Class { __includes = SignalObject,
  init = function(self)
    SignalObject.init(self)
  end
}

return Map