local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local SpriteBank = require 'engine.utils.sprite_bank'

local SpriteViewer = Class {
  init = function(self, initialX, initialY)
    self.initialX = initialX or 24
    self.initialY = initialY or 24
    
    self.searchText = ''
    
    self.spriteName = ''
    self.sprite = nil
    self.spriteCanvas = love.graphics.newCanvas(1, 1)
    
    self.zoomLevels = { 1, 2, 4, 6, 8, 12 }
    self.zoom = 1
    self.canvasCache = { 
      ['1x1'] = self.spriteCanvas
    }
  end
}

function SpriteViewer:initialize()
  self.sprite = nil
  self.searchText = ''
  self.spriteName = ''
  self.spriteCanvas = self.canvasCache['1x1']
end

function SpriteViewer:drawSpriteOnSpriteCanvas()
  if not self.sprite then
    return
  end
  local w, h = self.spriteCanvas:getDimensions()
  love.graphics.setCanvas(self.spriteCanvas)
  love.graphics.clear()
  self.sprite:draw(w / 2, h / 2)
  love.graphics.setCanvas()
end

function SpriteViewer:updateSprite(spriteName)
  if spriteName == self.spriteName then
    return
  end
  if not SpriteBank.sprites[spriteName] then
    return
  end

  self.spriteName = spriteName
  local sprite = SpriteBank.getSprite(spriteName)
  local w, h = sprite:getDimensions()
  local canvasCacheKey = tostring(w) .. 'x' .. tostring(h)
  if not self.canvasCache[canvasCacheKey] then
    local canvas = love.graphics.newCanvas(w, h)
    canvas:setFilter('nearest', 'nearest')
    self.canvasCache[canvasCacheKey] = canvas
  end
  self.spriteCanvas = self.canvasCache[canvasCacheKey]
  self.sprite = sprite
end

function SpriteViewer:update(dt)
  Slab.BeginWindow('sprite-viewer', { Title = 'Sprite Viewer', X = self.initialX, Y = self.initialY})
  Slab.Text('Sprite')
  if Slab.Input('sprite-search', { Text = self.searchText, ReturnOnText = true }) then
    self.searchText = Slab.GetInputText()
  end
  self.searchText = self.searchText:gsub("^%s*(.-)%s*$", "%1")
  self:updateSprite(self.searchText)
  
  Slab.Text('Zoom')
  local selectedZoom = self.zoom
  if Slab.BeginComboBox('spriteset-zoom-combobox', { Selected = selectedZoom}) then
    for _, v in ipairs(self.zoomLevels) do
      if Slab.TextSelectable(v) then
        self.zoom = v
      end
    end
    Slab.EndComboBox()
  end
  
  if self.sprite and self.spriteCanvas then
    Slab.Image('sprite-canvas-' .. self.spriteName, {Image = self.spriteCanvas, WrapH = 'clampzero', WrapV = 'clampzero', ScaleX = self.zoom, ScaleY = self.zoom})
  end
  Slab.EndWindow()
end

function SpriteViewer:draw()
  self:drawSpriteOnSpriteCanvas()
end

return SpriteViewer