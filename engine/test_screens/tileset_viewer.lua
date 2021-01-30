local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local TilesetBank = require 'engine.utils.tileset_bank'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'

local tileMargin = 1
local tilePadding = 1

local TilesetViewer = Class {
  init = function(self)
    -- tileset stuff
    self.tilesetName = ''
    self.tileset = nil
    self.tilesetList = { }
    self.tilesetCanvas = love.graphics.newCanvas(1, 1)
    self.selectedTileIndexX = 1
    self.selectedTileIndexY = 1
    
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
  self.tilesetCanvas = self.canvasCache[self.tilesetName]
end

function TilesetViewer:drawTilesetOnTilesetCanvas()
  love.graphics.setCanvas(self.tilesetCanvas)
  love.graphics.clear()
  -- draw tiles
  local tileSize = self.tileset.tileSize
  for x = 1, self.tileset.sizeX, 1 do
    for y = 1, self.tileset.sizeY, 1 do
      local tilesetData = self.tileset:getTile(x, y)
      local sprite = tilesetData:getSprite()
      local posX = ((x - 1) * tileSize) + ((x - 1) * tilePadding) + (tileMargin)
      local posY = ((y - 1) * tileSize) + ((y - 1) * tilePadding) + (tileMargin)
      sprite:draw(posX + tileSize / 2 , posY + tileSize / 2)
    end
  end
  -- draw border around selected tile
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle('line', 
    ((self.selectedTileIndexX - 1) * tileSize) + ((self.selectedTileIndexX - 1) * tilePadding) + tileMargin, 
    ((self.selectedTileIndexY - 1) * tileSize) + ((self.selectedTileIndexY - 1) * tilePadding) + tileMargin, 
    tileSize, 
    tileSize) 
  
  love.graphics.setCanvas()
end

function TilesetViewer:updateSelectedTileIndex(x, y)
  if 1 <= x and x <= self.tileset.sizeX and 1 <= y and y <= self.tileset.sizeY then
    self.selectedTileIndexX = x
    self.selectedTileIndexY = y
  end
end

function TilesetViewer:enter(prev, ...)
  assert(lume.count(TilesetBank.tilesets) > 0, 'TilesetBank needs at least 1 tileset in order for TilesetViewer to use')
  for k, _ in pairs(TilesetBank.tilesets) do
    lume.push(self.tilesetList, k)
  end
  lume.sort(self.tilesetList, function(a, b)
    return string.upper(a) < string.upper(b)
  end)
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

  if self.tilesetCanvas then
    local wx, wy = Slab.GetWindowPosition()
    local tilesetImagePosX, tilesetImagePosY = Slab.GetCursorPos({Absolute = true})
    tilesetImagePosX, tilesetImagePosY = vector.sub(tilesetImagePosX, tilesetImagePosY, wx, wy)
    Slab.Image('tile-canvas-' .. self.tilesetName , {Image = self.tilesetCanvas, WrapH = 'clampzero', WrapV = 'clampzero', ScaleX = self.zoom, ScaleY = self.zoom})
    if Slab.IsMouseClicked(1) and not Slab.IsVoidClicked(1) then
      local mx, my = Slab.GetMousePosition()
      local windowClickX, windowClickY = vector.sub(mx, my, wx, wy)
      local relClickX, relClickY = vector.div(self.zoom, vector.sub(windowClickX, windowClickY, tilesetImagePosX, tilesetImagePosY))
      -- add 1 for lua index
      local tileIndexX = math.floor(relClickX / self.tileset.tileSize) + 1
      local tileIndexY = math.floor(relClickY / self.tileset.tileSize) + 1

      self:updateSelectedTileIndex(tileIndexX, tileIndexY)
    end
  end
  Slab.EndWindow()
end

function TilesetViewer:draw()
  self:drawTilesetOnTilesetCanvas()
  Slab.Draw()
end

return TilesetViewer