local Class = require 'lib.class'
local lume = require 'lib.lume'
local SpriteBank = require 'engine.utils.sprite_bank'
local PaletteBank = require 'engine.utils.palette_bank'
local TileData = require 'engine.tiles.tile_data'

local DEFAULT_TILE_SIZE = 16

local Tileset = Class {
  init = function(self, name, sizeX, sizeY, tileSize)
    self.tileSize = tileSize or DEFAULT_TILE_SIZE
    self.name = name
    self.aliasName = nil
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

--[[ 
  NB: Tileset alias names are NOT unique
  Alias names are used in tilesets
  Use Case: Autumn theme and Winter Theme will both have a Cave tileset. 
  You can make two tilesets 'cave_autumn' and 'cave_winter'
  These tilesets will then have the alias name 'cave'
]]
function Tileset:setAliasName(aliasName)
  self.aliasName = aliasName
end

function Tileset:getAliasName()
  if self.aliasName then
    return self.aliasName
  end
  return self:getName()
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
    assert(self.tiles[x].id == x, 'miscalculated tile id')
    return self.tiles[x]
  end
  local idx = (x - 1) * self.sizeY + y
  assert(idx <= self.size, '( ' .. tostring(x) .. ', ' .. tostring(y) .. ') is out of bounds')
  assert(idx == self.tiles[idx].id, 'miscalculated tile id')
  return self.tiles[idx]
end

function Tileset:setTile(tileData, x, y)
  tileData.id = self.tileId
  if y == nil then
    assert(x <= self.size, 'x is out of bounds')
    self.tiles[x] = tileData
    tileData.id = x
  else
    local idx = (x - 1) * self.sizeY + y
    assert(idx <= self.size, '( ' .. tostring(x) .. ', ' .. tostring(y) .. ') is out of bounds')
    self.tiles[idx] = tileData
    tileData.id = idx
  end
end

function Tileset:getSize()
  return self.size
end

function Tileset:createTileData(template)
  if template then
    return TileData.createFromTemplate(template)
  end
  return TileData()
end

return Tileset