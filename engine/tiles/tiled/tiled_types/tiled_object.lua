local Class = require 'lib.class'

---@class TiledObject
---@field id integer
---@field name string?
---@field objectType string?
---@field tiledType string?
---@field x integer?
---@field y integer?
---@field width integer?
---@field height integer?
---@field points table[]?
---@field properties table?
---@field rotation number?
---@field jid integer?
local TiledObject = Class {
  init = function(self)
    self.id = -1
    self.name = nil
    self.objectType = nil
    self.tiledType = nil
    self.x, self.y = nil, nil
    self.width, self.height = nil, nil
    -- array of points {x, y}
    self.points = nil
    self.properties = { }
    self.rotation = nil
    self.jid = nil
  end
}

function TiledObject:getType()
  return 'tiled_object'
end

function TiledObject:getTiledType()
  return self.tiledType
end

return TiledObject