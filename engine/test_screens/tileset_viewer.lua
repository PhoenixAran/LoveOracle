local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local TilesetBank = require 'engine.utils.tileset_bank'

local tileMargin = 1
local tilePadding = 1

local TilesetViewer = Class {
  init = function(self)
    -- tileset stuff
    self.tilesetName = ''
    self.tileset = nil
    self.tilesetList = { }
    self.tileCanvas = love.graphics.newCanvas(1, 1)
    self.zoomLevels = { 1, 2, 4, 6, 8, 12 }
    self.zoom = 1
    self.canvasCache = { }
  end
}

function TilesetViewer:updateTileset(tilesetName)
  if tilesetName == self.tilesetName then 
    return
  end
  self.tilesetName = tilesetName
  self.tileset = TilesetBank.getTileset(self.tilesetName)
  if not self.canvasCache[self.tilesetName] then
    local canvasW = (self.tileset.tileSize * self.tileset.sizeX) + ((self.tileset.sizeX - 1) * tilePadding) + (tileMargin * 2)
    local canvasH = (self.tileset.tileSize * self.tileset.sizeY) + ((self.tileset.sizeY - 1) * tilePadding) + (tileMargin * 2)
    local canvas = love.graphics.newCanvas(canvasW, canvasH)
    canvas:setFilter('nearest', 'nearest')
    self.canvasCache[self.tilesetName] = canvas
  end
  self.tileCanvas = self.canvasCache[self.tilesetName]
  self.tileCanvasDrawn = false
end

function TilesetViewer:drawTilesetOnTileCanvas()
  love.graphics.setCanvas(self.tileCanvas)
  -- draw tiles
  local x = tilesetDrawMargin
  local y = tilesetPadding
  local tileSize = self.tileset.tileSize
  for x = 1, self.tileset.sizeX, 1 do
    for y = 1, self.tileset.sizeY, 1 do
      local tilesetData = self.tileset:getTile(x, y)
      local sprite = tilesetData:getSprite()
      local posX = ((x - 1) * 16) + ((x - 1) * tilePadding) + (tileMargin)
      local posY = ((y - 1) * 16) + ((y - 1) * tilePadding) + (tileMargin)
      sprite:draw(posX + tileSize / 2 , posY + tileSize / 2)
    end
  end
  self.tileCanvasDrawn = true
  love.graphics.setCanvas()
end

function TilesetViewer:enter(prev, ...)
  assert(lume.count(TilesetBank.tilesets) > 0, 'TilesetBank needs at least 1 tileset in order for TilesetViewer to use')
  for k, _ in pairs(TilesetBank.tilesets) do
    lume.push(self.tilesetList, k)
  end
  self:updateTileset(lume.first(self.tilesetList))
  Slab.Initialize()
end


function TilesetViewer:update(dt)
  Slab.Update(dt)
  Slab.BeginWindow('tileset-viewer', { Title = 'Tileset Viewer'})
  
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
  if Slab.BeginComboBox('zoom-combobox', {Selected = selectedZoom }) then
    for _, v in ipairs(self.zoomLevels) do
      if Slab.TextSelectable(v) then
        self.zoom = v
      end
    end
    Slab.EndComboBox()
  end
  
  if self.tileCanvas then
    Slab.Image('tile-canvas-' .. self.tilesetName , {Image = self.tileCanvas, WrapH = 'clampzero', WrapV = 'clampzero', ScaleX = self.zoom, ScaleY = self.zoom})
  end
  Slab.EndWindow()
end

function TilesetViewer:draw()
  self:drawTilesetOnTileCanvas()
  Slab.Draw()
end


return TilesetViewer