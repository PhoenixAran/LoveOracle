local Class = require 'lib.class'
local imgui = require 'imgui'
local lume = require 'lib.lume'
local Direction4 = require 'engine.enums.direction4'
local SpriteBank = require 'engine.banks.sprite_bank'

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

-- TODO add animatiom source Entity so we can also view hitboxes
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
---@field animViewerCurrentDir4 string
---@field animViewerTick integer
---@field animViewerFrameIndex integer
---@field animViewerPlaying boolean
---@field animViewerCurrentSprite Sprite|CompositeSprite|ColorSprite|PrototypeSprite|nil
---@field animViewerDrawCenterPoint boolean
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

    self.animViewerAnimationSelect = { }
    self.animViewerAnimationSelectIdx = 1
    self.animViewerCurrentAnimation = nil

    -- we add 1 for the default animation
    self.animViewerDir4Select = {'right', 'down', 'left', 'up' , 'default'}
    self.animViewerDir4Idx = 1
    self.animViewerCurrentDir4 = nil

    self.animViewerFrameIndex = 1
    self.animViewerTick = 1
    self.animViewerPlaying = false
    self.animViewerCurrentSprite = nil
    self.animViewerSpriteEntity = nil
    self.animViewerDrawCenterPoint = false

    --self.entityScriptList = { }
  end
}

-- roomy callbacks
function ContentViewer:enter(prev, ...)
  -- init animation viewer stuff
  -- man handle self.animViewerCurrentBuilder
  self.animViewerCurrentBuilder = SpriteBank.builders[lume.first(getKeyList(SpriteBank.builders))]
  assert(self.animViewerCurrentBuilder, 'Atleast one builder is required on startup')
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
    --imgui.Image(self.animViewerCanvas, self.animViewerCanvas:getWidth(), self.animViewerCanvas:getHeight())

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
        if imgui.BeginCombo('Builder', self.animViewerBuilderSelect[self.animViewerBuilderIdx]) then
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
              if lume.any(self.animViewerAnimationSelect) then
                self.animViewerCurrentAnimation = self.animViewerCurrentBuilder.animations[lume.first(self.animViewerAnimationSelect)]
              end

              -- reset anim playing variables
              self.animViewerTick = 1
              self.animViewerFrameIndex = 1
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
            if self.animViewerCurrentSource == AnimationSource.Builder then
              self.animViewerCurrentAnimation = self.animViewerCurrentBuilder.animations[v]
            else  -- we are using animations straight from SpriteBank.animations
              self.animViewerCurrentAnimation = SpriteBank.animations[v]
            end

            -- reset anim playing variables
            self.animViewerTick = 1
            self.animViewerFrameIndex = 1
          end

          if isSelected then
            imgui.SetItemDefaultFocus()
          end
        end
        imgui.EndCombo()
      end
    else
      imgui.Text('No animations found')
    end

    if self.animViewerCurrentAnimation then
      if self.animViewerCurrentAnimation:hasSubstrips() then
        if imgui.BeginCombo('Substrip', self.animViewerDir4Select[self.animViewerDir4Idx]) then
          for k, v in ipairs(self.animViewerDir4Select) do
            local isSelected = self.animViewerDir4Idx == k

            if imgui.Selectable(self.animViewerDir4Select[k], isSelected) then
              -- update animation substrip selection
              self.animViewerDir4Idx = k
              self.animViewerCurrentDir4 = v

              -- reset anim playing variables
              self.animViewerTick = 1
              self.animViewerFrameIndex = 1
            end

            if isSelected then
              imgui.SetItemDefaultFocus()
            end
          end
          imgui.EndCombo()
        end
      end
    end

    -- animation tick state
    imgui.Separator()
    imgui.Image(self.animViewerCanvas, self.animViewerCanvas:getWidth(), self.animViewerCanvas:getHeight())
    assert(self.animViewerCurrentAnimation:getSpriteFrames(), 'Expected an animation instance. Did you forget to set a default substrip?')
    local frameIndex = imgui.SliderInt('Frame', self.animViewerFrameIndex, 1, lume.count(self.animViewerCurrentAnimation:getSpriteFrames()))
    if frameIndex ~= self.animViewerFrameIndex then
      self.animViewerFrameIndex = frameIndex
      self.animViewerPlaying = false
      self.animViewerTick = 1
    end

    if self.animViewerPlaying then
      if imgui.Button('Pause') then
        self.animViewerPlaying = false
      end
    else
      if imgui.Button('Play') then
        self.animViewerPlaying = true
      end
    end
    imgui.SameLine()
    if imgui.Button('Stop') then
      self.animViewerPlaying = false
      self.animViewerTick = 1
      self.animViewerFrameIndex = 1
    end

    self.animViewerDrawCenterPoint = imgui.Checkbox('Draw Center', self.animViewerDrawCenterPoint)

    -- sprite animation logic below
    ---@type any
    local substripValue = nil
    if self.animViewerCurrentDir4 == 'default' then
      substripValue = self.animViewerCurrentDir4
    else
      substripValue = Direction4[self.animViewerCurrentDir4]
    end

    -- altered duped logic from AnimatedSpriteRenderer:update() function
    --- @type SpriteFrame[]
    local spriteFrames = self.animViewerCurrentAnimation:getSpriteFrames(substripValue)

    if self.animViewerPlaying then
      -- draw the animation on our canvas
      if lume.count(spriteFrames) > 0 then
        local currentFrame = spriteFrames[self.animViewerFrameIndex]
        self.animViewerTick = self.animViewerTick + 1
        if currentFrame:getDelay() < self.animViewerTick then
          self.animViewerTick = 1
          self.animViewerFrameIndex = self.animViewerFrameIndex + 1
          if lume.count(spriteFrames) < self.animViewerFrameIndex then
            self.animViewerFrameIndex = 1
          end
        end
        currentFrame = spriteFrames[self.animViewerFrameIndex]
        self.animViewerCurrentSprite = currentFrame:getSprite()
      end
    else
      self.animViewerCurrentSprite = spriteFrames[self.animViewerFrameIndex]:getSprite()
    end

    imgui.End()
  end -- end animation viewer
end

function ContentViewer:draw()
  -- clear screen
  love.graphics.clear(195 / 255, 125 / 255, 130 / 255)

  local animViewerCanvasScale = self.animViewerCanvasScaleSelect[self.animViewerCanvasScaleIdx]
  if animViewerCanvasScale > 1 then
    love.graphics.push()
    love.graphics.scale(animViewerCanvasScale)
  end

  -- set animation viewer canvas as current target
  love.graphics.setCanvas(self.animViewerCanvas)
  love.graphics.clear(.4, .4, .4, 1.0)
  local animCanvasCenterX = (self.animViewerCanvas:getPixelWidth() / animViewerCanvasScale) / 2
  local animCanvasCenterY = (self.animViewerCanvas:getPixelHeight() / animViewerCanvasScale) / 2

  -- draw animation on animation viewer canvas
  if self.animViewerCurrentSprite then
    self.animViewerCurrentSprite:draw(animCanvasCenterX, animCanvasCenterY)
  end

  -- draw center point
  if self.animViewerDrawCenterPoint then
    local crosshairLen = 6
    love.graphics.line(animCanvasCenterX,animCanvasCenterX - (crosshairLen / 2), animCanvasCenterX,animCanvasCenterY + (crosshairLen / 2))
    love.graphics.line(animCanvasCenterX - (crosshairLen / 2),animCanvasCenterY, animCanvasCenterX + (crosshairLen / 2),animCanvasCenterY)
  end

  if animViewerCanvasScale > 1 then
    love.graphics.pop()
  end

  -- set canvas to screen canvas
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

    local animationKeys = getKeyList(self.animViewerCurrentBuilder.animations)
    lume.push(self.animViewerAnimationSelect, unpack(animationKeys))

    if lume.any(self.animViewerAnimationSelect) then
      self.animViewerCurrentAnimation = self.animViewerCurrentBuilder.animations[lume.first(self.animViewerAnimationSelect)]
    end
  else
    local animationKeys = getKeyList(SpriteBank.animations)
    lume.push(self.animViewerAnimationSelect, unpack(animationKeys))

    if lume.any(self.animViewerAnimationSelect) then
      self.animViewerCurrentAnimation = SpriteBank.animations[lume.first(self.animViewerAnimationSelect)]
    end
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