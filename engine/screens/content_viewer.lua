local Class = require 'lib.class'
local imgui = require 'imgui'
local lume = require 'lib.lume'
local Direction4 = require 'engine.enums.direction4'

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

local AnimationSource = {
  Builder = 'Sprite Renderer Builders',
  Singular = 'Singular Animations'
}

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
---@field animViewerSourceSelect string[]
---@field animViewerSourceIdx integer
---@field entityScriptList string[]
---@field animViewerSourceType integer
---@field animSelectSource string[]
---@field animViewerCurrentSource string
---@field animViewerBuilderSelect string[]
---@field animViewerBuilderIdx integer
---@field animViewerBuilder SpriteRendererBuilder
---@field animViewerAnimationSelectIdx integer
---@field animViewerAnimationSelect string[]
---@field animViewerCurrentAnimation SpriteAnimation
---@field animViewerDir4Select string[]
---@field animViewerDir4Idx integer
---@field 
local ContentViewer = Class {
  init = function(self)
    -- animation viewer 
    self.showAnimViewer = true
    self.animViewerCanvasCache = {
      ['32x32'] = love.graphics.newCanvas(32, 32),
      ['64x64'] = love.graphics.newCanvas(64, 64),
      ['128x128'] = love.graphics.newCanvas(128, 128),
      ['240x240'] = love.graphics.newCanvas(240, 240),
      ['500x500'] = love.graphics.newCanvas(500, 500),
      ['800x600'] = love.graphics.newCanvas(800, 600)
    }
    self.animViewerCanvasSizeSelect = { '32x32', '64x64', '128x128', '240x240', '500x500', '800x600'}
    self.animViewerCanvasScaleSelect = { 1, 2, 4, 8 }
    self.animViewerCanvasSizeIdx = 3
    self.animViewerCanvasScaleIdx = 2
    self.animViewerCanvas = self.animViewerCanvasCache[self.animViewerCanvasSizeSelect[self.animViewerCanvasSizeIdx]]

    self.animViewerSourceSelect = { AnimationSource.Builder, AnimationSource.Singular }
    self.animViewerSourceIdx = 1
    self.animViewerCurrentSource = AnimationSource.Builder

    self.animViewerBuilderSelect = { }
    self.animViewerBuilderIdx = 1
    self.animViewerCurrentBuilder = nil
    self.animViewerSpriteEntity = nil

    self.animViewerAnimationSelect = { }
    self.animViewerAnimationSelectIdx = 1
    self.animViewerCurrentAnimation = nil

    self.animViewerDir4Select = { 'right', 'down', 'left', 'up' }
    self.animViewerDir4Idx = 1

    self.entityScriptList = { }
  end
}

-- roomy callbacks
function ContentViewer:enter(prev, ...)
  -- init animation viewer stuff
  self:updateAnimationViewerSource(true)

end

function ContentViewer:update(dt)
  imgui.NewFrame()

  if imgui.BeginMainMenuBar() then
    if imgui.MenuItem('Animation Viewer') then
      self.showAnimViewer = not self.showAnimViewer
    end
    imgui.EndMainMenuBar()
  end

  if self.showAnimViewer then
    imgui.Begin('Animation Viewer', true, "ImGuiWindowFlags_AlwaysAutoResize")
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
      imgui.EndCombo()
    end

    if imgui.BeginCombo('Animation Source', self.animViewerSourceSelect[self.animViewerSourceIdx]) then
      for k, v in ipairs(self.animViewerSourceSelect) do
        local isSelected = self.animViewerSourceIdx == k

        if imgui.Selectable(self.animViewerSourceSelect[k], isSelected) then
          -- update animation source
          self.animViewerSourceIdx = k
          self:updateAnimationViewerSource()
        end

        if isSelected then
          imgui.SetItemDefaultFocus()
        end
      end
      imgui.EndCombo()
    end

    if self.animViewerCurrentSource == AnimationSource.Builder then
      if lume.count(self.animViewerBuilderSelect) > 0 then
        if imgui.BeginCombo('Entity', self.animViewerBuilderSelect[self.animViewerBuilderIdx]) then
          for k, v in ipairs(self.animViewerBuilderSelect) do
            local isSelected = self.animViewerBuilderIdx == k

            if imgui.Selectable(self.animViewerBuilderSelect[k], isSelected) then
              -- update animation builder source
              self.animViewerBuilderIdx = k
              self.animViewerCurrentBuilder = SpriteBank.builders[v]
              
              -- update animation select
              lume.clear(self.animViewerAnimationSelect)
              self.animViewerAnimationSelectIdx = 1
              lume.push(self.animViewerAnimationSelect, unpack(getKeyList(self.animViewerCurrentBuilder.animations)))
            end

            if isSelected then
              imgui.SetItemDefaultFocus()
            end
          end
          imgui.EndCombo()
        end
      else
        imgui.Text('No builders found')
      end
    end

    if lume.count(self.animViewerAnimationSelect) > 0 then
      if imgui.BeginCombo('Animation', self.animViewerAnimationSelect[self.animViewerAnimationSelectIdx]) then
        for k, v in ipairs(self.animViewerAnimationSelect) do
          local isSelected = self.animViewerAnimationSelectIdx == k
          
          if imgui.Selectable(self.animViewerAnimationSelect[k], isSelected) then
            -- update animation select
            self.animViewerAnimationSelectIdx = k
            self.animViewerCurrentAnimation = self.animViewerCurrentBuilder.animations[v]
          end
        end
        imgui.EndCombo()
      end
    else
      imgui.Text('No animations found')
    end

    local hasSubstrips = false 
    if self.animViewerCurrentBuilder then
      
    elseif self.animViewerCurrentAnimation then
      
    end
  end
end

function ContentViewer:draw()
  -- animation viewer canvas
  love.graphics.clear(202 / 255, 103 / 255, 2 / 255)
  love.graphics.setCanvas(self.animViewerCanvas)
  local animViewerCanvasScale = self.animViewerCanvasScaleSelect[self.animViewerCanvasScaleIdx]
  if animViewerCanvasScale > 1 then
    love.graphics.push()
    love.graphics.scale(animViewerCanvasScale)
  end
  love.graphics.clear(204 / 255, 204 / 255, 204 / 255)
  if animViewerCanvasScale > 1 then
    love.graphics.pop()
  end
  love.graphics.setCanvas()
  imgui.Render()
end

-- ContentViewer functions

--- reset some fields when the user updates what kind of animation source we are viewing
function ContentViewer:updateAnimationViewerSource(forceUpdate)
  local source = self.animViewerSourceSelect[self.animViewerSourceIdx]
  if source == self.animViewerCurrentSource and not forceUpdate then
    return
  end

  lume.clear(self.animViewerBuilderSelect)
  self.animViewerBuilderIdx = 1
  lume.clear(self.animViewerAnimationSelect)
  self.animViewerAnimationSelectIdx = 1
  self.animViewerCurrentSource = source

  if source == AnimationSource.Builder then
    local builderKeys = getKeyList(SpriteBank.builders)
    lume.push(self.animViewerBuilderSelect, unpack(builderKeys))
    
    --TODO set animation key list on initial load
    local animationKeys = getKeyList(self.animViewerCurrentBuilder.animations)
    lume.push(self.animViewerAnimationSelect, unpack(animationKeys))
  else
    local animationKeys = getKeyList(SpriteBank.animations)
    lume.push(self.animViewerAnimationSelect, unpack(animationKeys))
  end
end

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