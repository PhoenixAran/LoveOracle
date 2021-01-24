local Class = require 'lib.class'
local lume = require 'lib.lume'
local SpriteBank = require 'engine.utils.sprite_bank'
local PaletteBank = require 'engine.utils.palette_bank'

local Tileset = Class {
  init = function(self, name)
    self.name = name
    -- holds TileData instances, don't confuse this with the Tile class
    self.tiles = { }
    self.count = nil
    self.rowCount = nil
    self.colCount = nil
    self.palette = nil
    -- tiles that ignore this tileset's palette
    self.paletteExceptionTiles = { }
  end
}

function Tileset:getName()
  return self.name
end

function Tileset:getType()
  return 'tileset'
end

function Tileset:hasPalette()
  return self.palette ~= nil
end

function Tileset:setPalette(paletteName)
  self.palette = PaletteBank.getPalette(paletteName)
end

function Tileset:getTile(x, y)
  if y == nil then
    return self.tiles[x]
  end
  return self.tiles[(x - 1) * self.colCount + y]
end

function Tileset:size()
  return lume.count(self.tiles)
end

-- Builder Methods
function Tileset:addTile(sprite)

end


return Tileset