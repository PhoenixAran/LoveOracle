local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local TilesetBank = require 'engine.utils.tileset_bank'

local TILE_MARGIN = 1
local TILE_PADDING = 1
-- IMGUI window to view tilesets
local TilesetViewer = Class {
  init = function(self, initialX, initialY)
    self.initialX = x or 24
    self.initialY = y or 24
    
    self.tilesetName = ''
    self.tileset = nil
    self.tilesetList = { }
    self.tilesetCanvas = love.graphics.newCanvas(1, 1)
    self.selectedTileIndexX = 1
    self.selectedTileIndexY = 1
    
    self.zoomLevels = { 1, 2, 4, 6, 8, 12 }
    self.zoom = 1
    self.canvasCache = {
      ['1x1'] = self.tilesetCanvas
    }
  end
}

function TilesetViewer:initialize()
  self.tilesetList = { }
  self.tileset = nil
  for k, _ in pairs(TilesetBank.tilesets) do 
    lume.push(self.tilesetList, k)
  end
  lume.sort(self.tilesetList, function(a, b)
    return string.upper(a) < string.upper(b)
  end)
  if lume.any(self.tilesetList, function(x) return x == self.tilesetName end) then
    self:updateTileset(self.tilesetName, true)
  elseif self.tilesetList[1] then
    self.tilesetName = self.tilesetList[1]
    self:updateTileset(self.tilesetName, true)
  end
end

function TilesetViewer:updateTileset(tilesetName, forceUpdate)
  if forceUpdate == nil then
    forceUpdate = false
  end
  if tilesetName == self.tilesetName and not forceUpdate then 
    return
  end
  self.tilesetName = tilesetName
  if not TilesetBank.tilesets[tilesetName] then
    return
  end
  self.tileset = TilesetBank.getTileset(self.tilesetName)
  if not self.canvasCache[self.tilesetName] then
    local canvasW = (self.tileset.tileSize * self.tileset.sizeX) + ((self.tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    local canvasH = (self.tileset.tileSize * self.tileset.sizeY) + ((self.tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    local canvas = love.graphics.newCanvas(canvasW, canvasH)
    canvas:setFilter('nearest', 'nearest')
    self.canvasCache[self.tilesetName] = canvas
  end
  self.tilesetCanvas = self.canvasCache[self.tilesetName]
end

function TilesetViewer:drawTilesetOnTilesetCanvas()
  love.graphics.setCanvas(self.tilesetCanvas)
  love.graphics.clear()

  if self.tileset then
    -- draw tiles
    local tileSize = self.tileset.tileSize
    for x = 1, self.tileset.sizeX, 1 do
      for y = 1, self.tileset.sizeY, 1 do
        local tilesetData = self.tileset:getTile(x, y)
        local sprite = tilesetData:getSprite()
        local posX = ((x - 1) * tileSize) + ((x - 1) * TILE_PADDING) + (TILE_MARGIN)
        local posY = ((y - 1) * tileSize) + ((y - 1) * TILE_PADDING) + (TILE_MARGIN)
        sprite:draw(posX + tileSize / 2 , posY + tileSize / 2)
      end
    end
  end
  -- draw border around selected tile
  love.graphics.setCanvas()
end

function TilesetViewer:update(dt)
  Slab.BeginWindow('tileset-viewer', { Title = 'Tileset Viewer', X = self.initialX, Y = self.initialY})
  
  Slab.Text('Tileset')
  local selected = self.tilesetName
  if Slab.BeginComboBox('tileset-combobox', {Selected = selected}) then
    for _, v in ipairs(self.tilesetList) do
      if Slab.TextSelectable(v) then
        self:updateTileset(v)
      end
    end
    Slab.EndComboBox()
  end
  
  Slab.Text('Zoom')
  local selectedZoom = self.zoom
  if Slab.BeginComboBox('tileset-zoom-combobox', {Selected = selectedZoom }) then
    for _, v in ipairs(self.zoomLevels) do
      if Slab.TextSelectable(v) then
        self.zoom = v
      end
    end
    Slab.EndComboBox()
  end

  if self.tilesetCanvas then
    Slab.Image('tile-canvas-' .. self.tilesetName , {Image = self.tilesetCanvas, WrapH = 'clampzero', WrapV = 'clampzero', ScaleX = self.zoom, ScaleY = self.zoom})
  end
  Slab.EndWindow()
end

function TilesetViewer:draw()
  self:drawTilesetOnTilesetCanvas()
end

return TilesetViewer