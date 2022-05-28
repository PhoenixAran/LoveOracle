local Class = require 'lib.class'

---@class TiledObjectLayer
---@field name string?
---@field objects table[]
---@field properties table
---@field type string
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