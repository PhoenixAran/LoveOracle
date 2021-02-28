local Class = require 'lib.class'
local lume = require 'lib.lume'
local inspect = require 'lib.inspect'
local Slab = require 'lib.slab'

local AssetManager = require 'engine.utils.asset_manager'
local BaseScreen = require 'engine.screens.base_screen'

local TILE_MARGIN = 1
local TILE_PADDING = 1

local MapEditor = Class { __include = BaseScreen,
  init = function(self)
    --[[
      Tileset Theme
    ]] 
    self.tilesetThemList = { }
    self.tilesetThemeName = ''
    self.tilesetTheme = nil
    
    self.tileset = nil
    self.tilesetList = { }
    self.tilesetCanvas = nil
    self.maxW = nil
    self.maxH = nil
    self.subW = nil
    self.subH = nil
    
    self.zoomLevels = { 1 2, 4, 7, 8, 12}
    self.zoom = 1
    self.hoverTileIndexX = nil
    self.hoverTileIndexY = nil
  end
}

function MapEditor:enter(prev, ...)
  
end

function MapEditor:update(dt)
  
end

function MapEditor:draw()
  
end

return MapEditor