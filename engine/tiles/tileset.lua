local Class = require 'lib.class'
local lume = require 'lib.lume'
local SpriteBank = require 'engine.utils.sprite_bank'
local PaletteBank = require 'engine.utils.palette_bank'
local TileData = require 'engine.tiles.tile_data'

local Tileset = Class {
  init = function(self, name, sizeX, sizeY, tileSize)
    
    self.tileSize = tileSize or 16
    self.tileId = 1
    self.name = name
    -- holds TileData instances, don't confuse this with the Tile class
    self.tiles = { }
    self.size = sizeX * sizeY
    self.sizeX = sizeX
    self.sizeY = sizeY
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
    assert(x <= self.size, 'x is out of bounds')
    return self.tiles[x]
  end
  local idx = (x - 1) * self.sizeY + y
  assert(idx <= self.size, '( ' .. tostring(x) .. ', ' .. tostring(y) .. ') is out of bounds')
  return self.tiles[idx]
end

function Tileset:setTile(tileData, x, y)
  tileData.id = self.tileId
  self.tileId = self.tileId + 1
  if y == nil then
    assert(x <= self.size, 'x is out of bounds')
    self.tiles[x] = tileData
  else
    local idx = (x - 1) * self.sizeY + y
    assert(idx <= self.size, '( ' .. tostring(x) .. ', ' .. tostring(y) .. ') is out of bounds')
    self.tiles[idx] = tileData
  end
end

function Tileset:count()
  return lume.count(self.tiles)
end

function Tileset:createTileData(template)
  if template then
    return TileData.createFromTemplate(template)
  end
  return TileData()
end



return Tileset