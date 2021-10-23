local class = require 'lib.class'

local TiledObjectLayer = Class {
  init = function(self)
    self.name = nil
    self.objects = { }
  end
}

return TiledObjectLayer