local Class = require 'lib.class'

local TiledObjectLayer = Class {
  init = function(self)
    self.name = nil
    self.objects = { }
    self.properties = { }
  end
}

function TiledObjectLayer:getType()
  return 'tiled_object_layer'
end

return TiledObjectLayer