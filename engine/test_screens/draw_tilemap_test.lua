local Class = require 'lib.class'
local lume = require 'lib.lume'
local Map = require 'engine.tiles.map'
local inspect = require ('lib.inspect').inspect
local Camera = require 'engine.camera'
local vector = require 'engine.math.vector'
local GRID_SIZE = require('constants').GRID_SIZE
local DisplayHandler = require 'engine.display_handler'
local DrawTilemapTest = Class {
  init = function(self)
    self.map = nil
    self.lastX, self.lastY = 0, 0
    self.x, self.y = 0, 0
  end
}

function DrawTilemapTest:enter(prev, ...)
  self.map = Map('test_map_1.json')
end

function DrawTilemapTest:update(dt)
  self.x, self.y = love.mouse.getPosition()
  if love.mouse.isDown(1) then
    local dx = self.lastX - self.x
    local dy = self.lastY - self.y
    --self.camera:move(dx * .8, dy * .8)
  end
  self.lastX, self.lastY = self.x, self.y
end

function DrawTilemapTest:draw()
  DisplayHandler.push()
  Camera.push()
  for layerIndex, tileLayer in ipairs(self.map.tileLayers) do
    for y = 1, self.map.height do
        for x = 1, self.map.width do
        local tileData = self.map:getTileData(x, y, layerIndex)
        if tileData then
          local posX, posY = vector.mul(GRID_SIZE, x, y)
          tileData.sprite:draw(posX - GRID_SIZE / 2, posY - GRID_SIZE / 2, false)
        end
      end
    end
  end
  Camera.pop()
  DisplayHandler.pop()
end

return DrawTilemapTest