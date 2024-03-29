local Class = require 'lib.class'
local lume = require 'lib.lume'
local BaseScreen = require 'engine.screens.base_screen'

local TiledMapLoader = require 'engine.tiles.tiled.tiled_map_loader'
local MapLoader = require 'engine.tiles.map_loader'
local Map = require 'engine.tiles.map'
local Singletons = require 'engine.singletons'
local DisplayHandler = require 'engine.display_handler'
local TiledMapLoaderTest = Class { __includes = BaseScreen,
  init = function(self)

  end
}

function TiledMapLoaderTest:enter(...)
  local inspect = require ('lib.inspect').inspect
  --local tiledMapData = TiledMapLoader.loadMapData('test_map_1.json')
  --print(inspect(tiledMapData.layers[1].tiles))
  --print(lume.count(tiledMapData.layers[1].tiles))
  --print('TileMapLoader success!')
  --local mapData = MapLoader.loadMapData('test_map_1.json')
  --print(inspect(TiledMapLoader.getTileset('proto_dungeon')))
  --print(inspect(MapLoader.getTileset('proto_dungeon')))
  --print(inspect(mapData))
  local map = Map('test_map_1.json')
  print(inspect(map))
  love.filesystem.write('map.txt', inspect(map))
  print('MapLoader success!')
end

function TiledMapLoaderTest:draw()
  DisplayHandler.push()
  love.graphics.print('It works')
  DisplayHandler.pop()
end

return TiledMapLoaderTest

