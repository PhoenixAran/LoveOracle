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
    self.tilesetCanvas = nil
    self.selectedTileIndexX = 1
    self.selectedTileIndexY = 1
    self.maxW = nil
    self.maxH = nil
    self.subW = nil
    self.subH = nil
    
    
    self.zoomLevels = { 1, 2, 4, 6, 8, 12 }
    self.zoom = 1
  end
}

function TilesetViewer:initialize()
  self.tilesetList = { }
  self.tileset = nil
  local maxW = 0
  local maxH = 0
  
  -- get the width and height of tileset since canvas will most likely be larger than the
  -- what is needed for tileset size 
  for k, tileset in pairs(TilesetBank.tilesets) do 
    -- push keys for the list box
    lume.push(self.tilesetList, k)
    local w = (tileset.tileSize * tileset.sizeX) + ((tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    local h = (tileset.tileSize * tileset.sizeY) + ((tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    maxW = math.max(maxW, w)
    maxH = math.max(maxH, h)
  end
  
  -- find the canvas width and height of largest tileset size
  if not self.tilesetCanvas then
    self.maxW = maxW
    self.maxH = maxH
      -- if this is first call to self:initialize, we need to create the canvas to draw the tileset canvas on
    self.tilesetCanvas = love.graphics.newCanvas(maxW, maxH)
    self.tilesetCanvas:setFilter('nearest', 'nearest')
  elseif self.maxW ~= maxW or self.maxH ~= maxH then
    -- not allowed to resize the largest tileset size on hot reloads
    -- since the canvas used to draw the tilesets cannot be released or resized 
    error('Tileset Viewer requires game reboot if largest tileset size changes in any way')
  end
  
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
  self.subW = (self.tileset.tileSize * self.tileset.sizeX) + ((self.tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
  self.subH = (self.tileset.tileSize * self.tileset.sizeY) + ((self.tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
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
        if tilesetData then
          local sprite = tilesetData:getSprite()
          local posX = ((x - 1) * tileSize) + ((x - 1) * TILE_PADDING) + (TILE_MARGIN)
          local posY = ((y - 1) * tileSize) + ((y - 1) * TILE_PADDING) + (TILE_MARGIN)
          sprite:draw(posX + tileSize / 2 , posY + tileSize / 2)
        end
      end
    end
  end
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
    Slab.Image('tile-canvas-' .. self.tilesetName , {Image = self.tilesetCanvas, WrapH = 'clampzero', WrapV = 'clampzero', ScaleX = self.zoom, ScaleY = self.zoom, SubW = self.subW, SubH = self.subH})
  end
  
  Slab.EndWindow()
end

function TilesetViewer:draw()
  self:drawTilesetOnTilesetCanvas()
end

return TilesetViewer