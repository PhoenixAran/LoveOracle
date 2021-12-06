local Class = require 'lib.class'
local lume = require 'lib.lume'
local BaseScreen = require 'engine.screens.base_screen'

local TiledMapLoader = require 'engine.tiles.tiled.tiled_map_loader'

local TiledMapLoaderTest = Class { __includes = BaseScreen,
  init = function(self)

  end
}

function TiledMapLoaderTest:enter(...)
  local inspect = require ('lib.inspect').inspect
  local map = TiledMapLoader.loadMapData('test_map_1.json')
  print(inspect(map.layers[1].tiles))
  print(lume.count(map.layers[1].tiles))
end

function TiledMapLoaderTest:draw()
  monocle:begin()
  love.graphics.print('It works')
  monocle:finish()
end

return TiledMapLoaderTest

