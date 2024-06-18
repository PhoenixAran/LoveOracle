local Class = require 'lib.class'
local lume = require 'lib.lume'
local Consts = require 'constants'

---@class MapData
---@field name string
---@field height integer
---@field width integer
---@field layerTilesets LayerTileset[]
---@field tileLayers TileLayer[]
---@field rooms Room[]
---@field testSpawnPositionX number
---@field testSpawnPositionY number
---@field initialSpawnPositionX number
---@field initialSpawnPositionY number
local MapData = Class {
  init = function(self)
    self.name = nil
    self.height = -1
    self.width = -1
    -- array of layer tilesets
    self.layerTilesets = { }
    -- array of tile layers
    self.tileLayers = { }
    -- array of room data
    self.rooms = { }

    -- used for testing
    self.testSpawnPositionX = nil
    self.testSpawnPositionY = nil

    self.initialSpawnPositionX = nil
    self.initialSpawnPositionY = nil
  end
}

function MapData:setTestSpawnPosition(x, y)
  self.testSpawnPositionX = x + Consts.GRID_SIZE / 2
  self.testSpawnPositionY = y - Consts.GRID_SIZE / 2
end

function MapData:setInitialSpawnPosition(x, y)
  self.initialSpawnPositionX = x + Consts.GRID_SIZE / 2
  self.initialSpawnPositionY = y - Consts.GRID_SIZE / 2
end

function MapData:getType()
  return 'map_data'
end

return MapData