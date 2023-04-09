local Class = require 'lib.class'
local imgui = require 'imgui'
local lume = require 'lib.lume'

local SpriteBank = require 'engine.utils.sprite_bank'

---@param t table
---@return any[]
local function getKeyList(t)
  local keyset = { }
  local n = 1
  for k, v in pairs(t) do
    keyset[n] = k
    n = n + 1
  end
  lume.sort(keyset)
  return keyset
end

---@class ContentViewer
---@field showAnimViewer boolean
---@field animViewerCanvas love.Canvas
---@field spriteAnimations string[]
---@field spriteBuilders string[]
---@field animViewerCanvasCache table<string, love.Canvas>
---@field animViewerCanvasScaleIdx integer
---@field animViewerCanvasSizeIdx integer
---@field animViewerCanvasSizeSelect string[]
---@field animViewerCanvasScaleSelect integer[]
---@field entityScriptList string[]
---@field animViewerSourceType integer
local ContentViewer = Class {
  init = function(self)
    -- animation viewer
    self.showAnimViewer = true
    self.animViewerCanvasCache = { 
      ['32x32'] = love.graphics.newCanvas(32, 32),
      ['64x64'] = love.graphics.newCanvas(64, 64),
      ['128x128'] = love.graphics.newCanvas(128, 128),
      ['240x240'] = love.graphics.newCanvas(240, 240)
    }
    self.animViewerCanvasSizeSelect = { '32x32', '64x64', '128x128', '240x240'}
    self.animViewerCanvasScaleSelect = { 1, 2, 4, 8 }
    self.animViewerCanvasSizeIdx = 3
    self.animViewerCanvasScaleIdx = 2
    self.animViewerCanvas = self.animViewerCanvasCache[self.animViewerCanvasSizeSelect[self.animViewerCanvasSizeIdx]]
    -- 1 = singular animation instance, 2 = sprite renderer instance
    self.animViewerSourceType = 1
    self.spriteAnimations = { }
    self.spriteBuilders = { }
    self.entityScriptList = { }

  end
}


-- roomy callbacks
function ContentViewer:enter(prev, ...)
  -- init animation viewer stuff
  self.spriteBuilders = getKeyList(SpriteBank.builders)
  self.spriteAnimations = getKeyList(SpriteBank.animations)
end

function ContentViewer:update(dt)
  imgui.NewFrame()

  if imgui.BeginMainMenuBar() then
    if imgui.MenuItem("Animation Viewer") then
      self.showAnimViewer = not self.showAnimViewer
    end
  end
  
  if self.showAnimViewer then
    imgui.Begin("Animation Viewer")
    imgui.Image(self.animViewerCanvas, self.animViewerCanvas:getWidth(), self.animViewerCanvas:getHeight())

    if imgui.BeginCombo('Canvas Size', self.animViewerCanvasSizeSelect[self.animViewerCanvasSizeIdx]) then
      for k, v in ipairs(self.animViewerCanvasSizeSelect) do
        local isSelected = self.animViewerCanvasSizeIdx == k
        
        if imgui.Selectable(self.animViewerCanvasSizeSelect[k], isSelected) then
          --update canvas size
          self.animViewerCanvasSizeIdx = k
          self.animViewerCanvas = self.animViewerCanvasCache[v]
        end

        if isSelected then
          imgui.SetItemDefaultFocus()
        end
      end
      imgui.EndCombo()
    end

    if imgui.BeginCombo('Canvas Scale', self.animViewerCanvasScaleSelect[self.animViewerCanvasScaleIdx]) then
      for k, v in ipairs(self.animViewerCanvasScaleSelect) do
        local isSelected = self.animViewerCanvasScaleIdx == k

        if imgui.Selectable(self.animViewerCanvasScaleSelect[k], isSelected) then
          -- update canvas scale
          self.animViewerCanvasScaleIdx = k
        end

        if isSelected then
          imgui.SetItemDefaultFocus()
        end
      end
    end

    imgui.Text('Animation Source')
    if imgui.RadioButton('Singular Animation', false) then
    end
    if imgui.RadioButton('Builder', false) then
    end
    imgui.End()
  end

  imgui.ShowDemoWindow(true)
end

function ContentViewer:draw()
  -- animation viewer canvas
  love.graphics.setCanvas(self.animViewerCanvas)
  local animViewerCanvasScale = self.animViewerCanvasScaleSelect[self.animViewerCanvasScaleIdx]
  if animViewerCanvasScale > 1 then
    love.graphics.push()
    love.graphics.scale(animViewerCanvasScale)
  end
  love.graphics.clear(204 / 255, 204 / 255, 204 / 255)
  love.graphics.print('hello world')
  if animViewerCanvasScale > 1 then
    love.graphics.pop()
  end
  love.graphics.setCanvas()

  imgui.Render()
end

-- functions


-- imgui hooks
function ContentViewer:textinput(t)
  imgui.TextInput(t)
end

function ContentViewer:keypressed(key)
  imgui.KeyPressed(key)
end

function ContentViewer:keyreleased(key)
  imgui.KeyReleased(key)
end

function ContentViewer:mousemoved(x, y)
  imgui.MouseMoved(x, y)
end

function ContentViewer:mousepressed(x, y, button)
  imgui.MousePressed(button)
end

function ContentViewer:mousereleased(x, y, button)
  imgui.MouseReleased(button)
end

function ContentViewer:wheelmoved(x, y)
  imgui.WheelMoved(y)
end


return ContentViewer