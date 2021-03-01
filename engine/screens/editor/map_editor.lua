local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local inspect = require 'lib.inspect'
local Slab = require 'lib.slab'

local AssetManager = require 'engine.utils.asset_manager'
local BaseScreen = require 'engine.screens.base_screen'

local TilesetTheme = require 'engine.tiles.tileset_theme'
local PaletteBank = require 'engine.utils.palette_bank'
local SpriteBank = require 'engine.utils.sprite_bank'
local TilesetBank = require 'engine.utils.tileset_bank'

local TILE_MARGIN = 1
local TILE_PADDING = 1

local MapEditorState = {
  Edit = 1,
  Play = 2
}

-- NB: Do not allow hot reloading when in map editor screen
local MapEditor = Class { __include = BaseScreen,
  init = function(self)
    --[[
      Tileset Theme
    ]]
    self.tilesetThemeList = { }
    self.tilesetThemeName = ''
    self.tilesetTheme = nil

    --[[
      Tileset
    ]]
    self.tileset = nil
    self.tilesetList = { }
    self.tilesetCanvas = nil
    self.maxW = nil
    self.maxH = nil
    self.subW = nil
    self.subH = nil
    self.selectedTileIndexX = nil
    self.selectedTileIndexY = nil
    self.hoverTileIndexX = nil
    self.hoverTileIndexY = nil
    self.selectedTileData = nil

    --[[
      Zoom
    ]]
    self.zoomLevels = { 1, 2, 4, 7, 8, 12}
    self.zoom = 1
  end
}

function MapEditor:updateTileset(tilesetThemeName, tilesetName, forceUpdate)
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

  -- get the width and height of tileset since canvas will most likely be larter
  -- than what is needed for tileset size
  self.tileset = self.tilesetTheme:getTileset(tilesetName)
  self.subW = (self.tileset.tileSize * self.tileset.sizeX) + ((self.tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
  self.subH = (self.tileset.tileSize * self.tileset.sizeY) + ((self.tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)

  -- update
  self.tilesetName = tilesetName
  self.tilesetThemeName = tilesetThemeName
end

function MapEditor:updateHoverTileIndex(x, y)

  if x == nil or y == nil then
    self.hoverTileIndex = nil
    self.hoverTileIndexY = nil
  elseif 1 <= x and x <= self.tileset.sizeX and 1 <= y and y <= self.tileset.sizeY then
    self.hoverTileIndexX = x
    self.hoverTileIndexY = y
  else
    self.hoverTileIndexX = nil
    self.hoverTileIndexY = nil
  end
end

function MapEditor:updateSelectedTileIndex(x, y)
  self.selectedTileIndexX = x
  self.selectedTileIndexY = y
  if x ~= nil and y ~= nil and 1 <= x and x <= self.tileset.sizeX and 1 <= y and y <= self.tileset.sizeY then
    local newTilesetData = self.tileset:getTile(x, y)
    if self.selectedTiletData == newTilesetData then
      -- deselect tile if we're clicking it while its selected
      self.selectedTileData = nil
    else
      self.selectedTileData = newTilesetData
    end
  end
end

-- roomy screen hooks
function MapEditor:enter(prev, ...)
  self.tilesetThemeList = { }
  self.tilesetTheme = nil
  local maxW, maxH = 1, 1
  -- find the canvas width and height of largest tileset size
  for _, tileset in pairs(TilesetBank.tilesets) do
    local w = (tileset.tileSize * tileset.sizeX) + ((tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    local h = (tileset.tileSize * tileset.sizeY) + ((tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    maxW = math.max(maxW, w)
    maxH = math.max(maxH, h)
  end
  self.tilesetCanvas = love.graphics.newCanvas(maxW, maxH)
  self.tilesetCanvas:setFilter('nearest', 'nearest')

  for k, _ in pairs(TilesetBank.tilesetThemes) do
    -- push keys for the list box
    lume.push(self.tilesetThemeList, k)
  end

  self.tilesetThemeName = self.tilesetThemeList[1] or ''
  self.tilesetList = TilesetTheme.getRequiredTilesets()
  self.tileset = nil
  self.tilesetName = self.tilesetList[1] or ''
  self:updateTileset(self.tilesetThemeName, self.tilesetName, true)
end

function MapEditor:update(dt)
  Slab.Update(dt)
  --[[
    MAIN MENU BAR
  ]]
  if Slab.BeginMainMenuBar() then
    if Slab.BeginMenu("File") then
      --TODO: File Explorer
      if Slab.MenuItemChecked('TODO') then

      end
      Slab.EndMenu()
    end
    if Slab.Button('Play') then
      print('TODO play test map')
      --TODO play test map
    end
    Slab.EndMainMenuBar()
  end

  --[[
    Tileset Window
  ]]
  Slab.BeginWindow('map-editor-tileset-window', { Title = "Tileset" })
  Slab.Text('Tileset Theme')
  local selectedTilesetThemeName = self.tilesetThemeName
  if Slab.BeginComboBox('map-editor-tileset-theme-combobox', {Selected = selectedTilesetThemeName}) then
    for _, v in ipairs(self.tilesetThemeList) do
      if Slab.TextSelectable(v) then
        selectedTilesetThemeName = v
      end
    end
    Slab.EndComboBox()
  end

  Slab.Text('Tileset')
  local selectedTilesetName = self.tilesetName
  if Slab.BeginComboBox('map-editor-tileset-comboxbox', {Selected = selectedTilesetName}) then
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
  if Slab.BeginComboBox('map-editor-tileset-zoom-combobox', {Selected = selectedZoom}) then
    for _, v in ipairs(self.zoomLevels) do
      if Slab.TextSelectable(v) then
        selectedZoom = v
      end
    end
    Slab.EndComboBox()
  end
  self.zoom = selectedZoom

  if self.tilesetCanvas then
    -- update hover tile
    local wx, wy = Slab.GetWindowPosition()
    local tilesetImagePosX, tilesetImagePosY = Slab.GetCursorPos({Absolute = true})
    tilesetImagePosX, tilesetImagePosY = vector.sub(tilesetImagePosX, tilesetImagePosY, wx, wy)
    Slab.Image('map-editor-tileset-canvas',
              {
                Image = self.tilesetCanvas,
                WrapH = 'clampzero', WrapV = 'clampzero',
                ScaleX = self.zoom, ScaleY = self.zoom ,
                SubX = 0, SubY = 0, SubW = self.subW, SubH = self.subH
              })
    local mx, my = Slab.GetMousePosition()
    mx, my = vector.sub(mx, my, wx, wy)
    local relx, rely = vector.div(self.zoom, vector.sub(mx, my, tilesetImagePosX, tilesetImagePosY))
    relx, rely = math.floor(relx), math.floor(rely)
    -- don't update if the mouse is inbetween the tiles (tile padding or tile margin)
    if relx == TILE_MARGIN or relx % (self.tileset.tileSize + TILE_PADDING) == 0
       or relx == self.tilesetCanvas:getWidth() then
       relx = -100
    end
    if rely == TILE_MARGIN or rely % (self.tileset.tileSize + TILE_PADDING) == 0
      or rely == self.tilesetCanvas:getHeight() then
      rely = -100
    end
    local tileIndexX = math.floor(relx / (self.tileset.tileSize + TILE_PADDING)) + 1
    local tileIndexY = math.floor(rely / (self.tileset.tileSize + TILE_PADDING)) + 1
    if Slab.IsMouseClicked(1) and not Slab.IsVoidClicked(1) then
      -- if we select one, display the tile data info
      self:updateSelectedTileIndex(tileIndexX, tileIndexY)
    end
    self:updateHoverTileIndex(tileIndexX, tileIndexY)
  end
  Slab.EndWindow()
end

function MapEditor:draw()
  Slab.Draw()
  -- draw tileset on tileset canvas
  love.graphics.setCanvas(self.tilesetCanvas)
  love.graphics.clear()
  local tileSize = self.tileset.tileSize
  for x = 1, self.tileset.sizeX, 1 do
    for y = 1, self.tileset.sizeY, 1 do
      local tilesetData = self.tileset:getTile(x, y)
      if tilesetData then
        local sprite = tilesetData:getSprite()
        local posX = ((x - 1) * tileSize) + ((x - 1) * TILE_PADDING) + (TILE_MARGIN)
        local posY = ((y - 1) * tileSize) + ((y - 1) * TILE_PADDING) + (TILE_MARGIN)
        sprite:draw(posX + tileSize / 2, posY + tileSize / 2)
      end
    end
  end
  if self.hoverTileIndexX ~= nil and self.hoverTileIndexY ~= nil then
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line',
      ((self.hoverTileIndexX - 1) * tileSize) + ((self.hoverTileIndexX - 1) * TILE_PADDING) + (TILE_MARGIN),
      ((self.hoverTileIndexY - 1) * tileSize) + ((self.hoverTileIndexY - 1) * TILE_PADDING) + (TILE_MARGIN),
      tileSize,
      tileSize)
  end
  if self.selectedTileData then
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line',
      ((self.selectedTileIndexX - 1) * tileSize) + ((self.selectedTileIndexX - 1) * TILE_PADDING) + (TILE_MARGIN),
      ((self.selectedTileIndexY - 1) * tileSize) + ((self.selectedTileIndexY - 1) * TILE_PADDING) + (TILE_MARGIN),
      tileSize,
      tileSize)
  end
  love.graphics.setCanvas()


end

return MapEditor
