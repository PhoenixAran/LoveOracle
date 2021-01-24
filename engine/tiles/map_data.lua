local Class = require 'lib.class'

local MapData = Class {
  init = function(self)
    self.layers = 2
    self.tiles = { }
  end
}



return MapData