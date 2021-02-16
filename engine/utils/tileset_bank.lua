local lume = require 'lib.lume'

local TileData = require 'engine.tiles.tile_data'
local Tileset = require 'engine.tiles.tileset'
local TilesetTheme = require 'engine.tiles.tileset_theme'
local GameConfig = require 'game_config'

local TilesetBank = {
  tilesets = { },
  tilesetThemes = { }
}

function TilesetBank.createTileset(name, sizeX, sizeY)
  return Tileset(name, sizeX, sizeY)
end

function TilesetBank.registerTileset(tileset)
  assert(TilesetBank.tilesets[tileset:getName()] == nil, 'TilesetBank already has tileset with key ' .. tileset:getName())
  TilesetBank.tilesets[tileset:getName()] = tileset
end

function TilesetBank.getTileset(name)
  assert(TilesetBank.tilesets[name], 'TilesetBank does not have any tileset with key ' .. name)
  return TilesetBank.tilesets[name]
end

function TilesetBank.createTilesetTheme(name)
  return TilesetTheme(name)
end

function TilesetBank.registerTilesetTheme(theme)
  local name = theme:getName()
  assert(not TilesetBank.tilesetThemes[name], 'TilesetBank already has tileset theme with name ' .. name)
  TilesetTheme.validateTheme(theme)
end

function TilesetBank.getTilesetTheme(name)
  assert(TilesetBank.tilesetThemes[name], 'TilesetBank does not have tileset theme with name ' .. name)
end

function TilesetBank.initialize()
  TilesetTheme.setRequiredTilesets(GameConfig.tilesetThemeRequirements)
  require('data.tile_templates')(TileData)
  require('data.tilesets')(TilesetBank)
  require('data.tileset_themes')(TilesetBank)
end

function TilesetBank.unload()
  TilesetBank.tilesets = { }
  TilesetBank.tilesetThemes = { }
  TilesetTheme.setRequiredTilesets({})
  TileData.clearTemplates()
end

return TilesetBank