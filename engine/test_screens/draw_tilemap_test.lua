local Class = require 'lib.class'
local lume = require 'lib.lume'
local Map = require 'engine.tiles.map'
local inspect = require ('lib.inspect').inspect
local Camera = require 'lib.camera'
local vector = require 'lib.vector'
local GRID_SIZE = 16

local DrawTilemapTest = Class {
  init = function(self)
    self.map = nil
  end
}

function DrawTilemapTest:enter(prev, ...)
  self.map = Map('test_map_1.json')
  print(inspect(self.map, {depth = 1}))
end

function DrawTilemapTest:update(dt)
  -- TODO control camera with mouse
end

function DrawTilemapTest:draw()
  monocle:begin()
  for layerIndex, tileLayer in ipairs(self.map.tileLayers) do
    for x = 1, self.map.width do
      for y = 1, self.map.height do
        local tileData = self.map:getTileData(x, y, layerIndex)
        if tileData then
          local posX, posY = vector.mul(GRID_SIZE, x, y)
          tileData.sprite:draw(posX - GRID_SIZE / 2, posY - GRID_SIZE / 2, false)
        end
      end
    end
  end
  monocle:finish()
end

return DrawTilemapTest