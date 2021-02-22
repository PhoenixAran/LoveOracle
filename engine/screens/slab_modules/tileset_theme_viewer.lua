local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local vector = require 'lib.vector'
local TilesetBank = require 'engine.utils.tileset_bank'
local TilesetTheme = require 'engine.tiles.tileset_theme'

local TILE_MARGIN = 1
local TILE_PADDING = 1

-- IMGUI window to view Tileset themes
local TilesetThemeViewer = Class {
  init = function(self, initialX, initialY)
    self.initialX = x or 24
    self.initialY = y or 24
    
    self.tilesetThemeList = { }
    self.tilesetThemeName = ''
    self.tilesetTheme = nil
    
    self.tileset = nil
    self.tilesetList = { }
    self.tilesetCanvas = love.graphics.newCanvas(1, 1)
    
    self.zoomLevels = { 1, 2, 4, 6, 8 , 12}
    self.zoom = 1
    self.canvasCache = {
        ['1x1'] = self.tilesetCanvas
    }
    self.hoverTileIndexX = nil
    self.hoverTileIndexY = nil
  end
}

function TilesetThemeViewer:initialize()
  self.tilesetThemeList = { }
  self.tilesetTheme = nil
  
  for k, _ in pairs(TilesetBank.tilesetThemes) do
    lume.push(self.tilesetThemeList, k)
  end
  
  if not lume.any(self.tilesetThemeList, function(x) return x == self.tilesetThemeName end) then
    self.tilesetThemeName = self.tilesetThemeList[1] or ''
  end
  
  self.tilesetList = TilesetTheme.getRequiredTilesets()
  self.tileset = nil
  
  if not lume.any(self.tilesetList, function(x) return x == self.tilesetName end) then
    self.tilesetName = self.tilesetList[1] or ''
  end
  
  self:updateTileset(self.tilesetThemeName, self.tilesetName, true)
end

function TilesetThemeViewer:updateTileset(tilesetThemeName, tilesetName, forceUpdate)
  if forceUpdate == nil then
    forceUpdate = false
  end
  if tilesetThemeName == self.tilesetThemeName and tilesetName == self.tilesetName and not forceUpdate then
    return
  end
  if tilesetThemeName == '' then
    return
  end
  self.tilesetTheme = TilesetBank.getTilesetTheme(tilesetThemeName)
  if tilesetName == '' then
    return
  end
  self.tileset = self.tilesetTheme:getTileset(tilesetName)
  -- make sure you don't use alias name to cache tileset canvases!
  -- alias names are NOT unique
  if not self.canvasCache[self.tileset:getName()] then
    local canvasW = (self.tileset.tileSize * self.tileset.sizeX) + ((self.tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    local canvasH = (self.tileset.tileSize * self.tileset.sizeY) + ((self.tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    local canvas = love.graphics.newCanvas(canvasW, canvasH)
    canvas:setFilter('nearest', 'nearest')
    self.canvasCache[self.tileset:getName()] = canvas
  end
  self.tilesetCanvas = self.canvasCache[self.tileset:getName()]
  
  self.tilesetName = tilesetName
  self.tilesetThemeName = tilesetThemeName
end

function TilesetThemeViewer:updateHoverIndex(x, y)
  if not self.tileset then
    return
  end
  if 1 <= x and x <= self.tileset.sizeX and 1 <= y and y <= self.tileset.sizeY then
    self.hoverTileIndexX = x
    self.hoverTileIndexY = y
  else
    self.hoverTileIndexX = nil
    self.hoverTileIndexY = nil
  end
end

function TilesetThemeViewer:drawTilesetOnTilesetCanvas()
  love.graphics.setCanvas(self.tilesetCanvas)
  love.graphics.clear(1, 1, 1)

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
    
    if self.hoverTileIndexX ~= nil and self.hoverTileIndexY ~= nil then
      love.graphics.setLineWidth(1)
      love.graphics.setColor(1, 0, 0)
      love.graphics.rectangle('line',
        ((self.hoverTileIndexX - 1) * tileSize) + ((self.hoverTileIndexX - 1) * TILE_PADDING) + TILE_MARGIN,
        ((self.hoverTileIndexY - 1) * tileSize) + ((self.hoverTileIndexY - 1) * TILE_PADDING) + TILE_MARGIN,
        tileSize,
        tileSize)
    end
  end
  love.graphics.setCanvas()
end

function TilesetThemeViewer:update(dt)
  Slab.BeginWindow('tileset-theme-viewer', { Title = 'Tileset Theme Viewer', X = self.initialX, Y = self.initialY})
  Slab.Text('Tileset Theme')
  local selectedTilesetThemeName = self.tilesetThemeName
  local selected = self.tilesetThemeName
  if Slab.BeginComboBox('tileset-theme-combobox', {Selected = selected}) then
    for _, v in ipairs(self.tilesetThemeList) do
      if Slab.TextSelectable(v) then
        selectedTilesetThemeName = v
      end
    end
    Slab.EndComboBox()
  end
  
  Slab.Text('Tileset')
  local selectedTilesetName = ''
  selected = self.tilesetName
  if Slab.BeginComboBox('tileset-theme-tileset-combobox', {Selected = selected}) then
    for _, v in ipairs(self.tilesetList) do
      if Slab.TextSelectable(v) then
        selectedTilesetName = v
      end
    end
    Slab.EndComboBox()
  end
  self:updateTileset(selectedTilesetThemeName, selectedTilesetName)
  Slab.Text('Zoom')
  local selectedZoom = self.zoom
  if Slab.BeginComboBox('tileset-theme-tileset-zoom-combobox', {Selected = selectedZoom }) then
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
    Slab.Image('tileset-canvas-' .. self.tilesetThemeName .. '-' .. self.tilesetName, { Image = self.tilesetCanvas, WrapH = 'clampzero', WrapV = 'clampzero', ScaleX = self.zoom, ScaleY = self.zoom })
    local mx, my = Slab.GetMousePosition()
    local windowHoverX, windowHoverY = vector.sub(mx, my, wx, wy)
    local relHoverX, relHoverY = vector.div(self.zoom, vector.sub(windowHoverX, windowHoverY, tilesetImagePosX, tilesetImagePosY))
    
    -- don't update if they click inbetween the tiles (tile padding or tile margin)
    print(relHoverX, relHoverY)
    if relHoverX == TILE_MARGIN or relHoverX % (self.tileset.tileSize + TILE_PADDING) == 0 or relHoverX == self.tilesetCanvas:getWidth() then
      relHoverX = -100
    end
    if relHoverY == TILE_MARGIN or relHoverY % (self.tileset.tileSize + TILE_PADDING) == 0 or relHoverY == self.tilesetCanvas:getHeight() then
      relHoverY = -100
    end
    
    
    local tileIndexX = math.floor(relHoverX / (self.tileset.tileSize + TILE_PADDING)) + 1
    local tileIndexY = math.floor(relHoverY / (self.tileset.tileSize + TILE_PADDING)) + 1

    self:updateHoverIndex(tileIndexX, tileIndexY)
    Slab.Text('Tile Name: ')
    Slab.SameLine()
    if self.hoverTileIndexX == nil then
      Slab.Text('')
    else
      local tilesetName = self.tileset:getTile(self.hoverTileIndexX, self.hoverTileIndexY):getName()
      Slab.Text(tilesetName)
    end
  end
  Slab.EndWindow()
end

function TilesetThemeViewer:draw()
  self:drawTilesetOnTilesetCanvas()
end

return TilesetThemeViewer