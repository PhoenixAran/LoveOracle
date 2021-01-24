local lume = require 'lib.lume'

local Tileset = require 'engine.tiles.tileset'

local TilesetBank = {
  tilesets = { }
}

function TilesetBank.createTileset(name, sizeX, sizeY)
  return Tileset(name, sizeX, sizeY)
end

function TilesetBank.register(tileset)
  assert(TilesetBank.tilesets[tileset:getName()] == nil, 'TilesetBank already has tileset with key ' .. tileset:getName())
  TilesetBank.tilesets[tileset:getName()] = tileset
end

function TilesetBank.getTileset(name)
  assert(TilesetBank.tilesets[name], 'TilesetBank does not have any tileset with key ' .. name)
  return TilesetBank.tilesets[name]
end

function TilesetBank.initialize(path)
  path = path or 'data.tiles'
  require(path)(TilesetBank)
end

return TilesetBank