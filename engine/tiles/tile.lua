local Class = require 'lib.class'
local lume = require 'lib.lume'
local bit = require 'bit'

local Tile = Class {
  init = function(self, tileData)
    -- use flyweight pattern via tileData instance
    self.data = tileData
  end
}

function Tile:getType()
  return 'tile'
end

function Tile:getTileData()
  return self.data
end

function Tile:isActionTile()
  return false
end

function Tile:isUpdatable()
  return false
end

function Tile:draw()
  
end

function Tile:pick()
  return nil
end

return Tile