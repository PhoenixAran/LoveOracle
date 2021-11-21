local Class = require 'lib.class'
local lume = require 'lib.lume'
local BaseScreen = require 'engine.screens.base_screen'

local MapLoader = require 'engine.tiles.tiled.map_loader'

local MapLoaderTest = Class { __includes = BaseScreen,
  init = function(self)

  end
}

function MapLoaderTest:enter(...)
  local inspect = require ('lib.inspect').inspect
  local tileset = MapLoader.loadTileset('data/tiled/tilesets/proto_dungeon.json')
  print(inspect(tileset, {
    depth = 2
  }))
  local map = MapLoader.loadMapData('data/tiled/maps/test_map_1.json')
  print(inspect(map, {
    depth = 4
  }))
end

function MapLoaderTest:draw()
  monocle:begin()
  love.graphics.print('It works')
  monocle:finish()
end

return MapLoaderTest

