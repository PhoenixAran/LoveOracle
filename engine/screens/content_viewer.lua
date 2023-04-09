local Class = require 'lib.class'
local imgui = require 'imgui'


---@class ContentViewer
---@field showAnimViewer boolean
---@field animViewerCanvas love.Canvas
---@field spriteAnimations SpriteAnimation[]
local ContentViewer = Class {
  init = function(self)
    self.showAnimViewer = true
    self.animViewerCanvas = love.graphics.newCanvas(128, 128)
    self.spriteAnimations = { }
  end
}


-- roomy callbacks
function ContentViewer:enter(prev, ...)
  
end

function ContentViewer:update(dt)
  imgui.NewFrame()
  if imgui.BeginMainMenuBar() then
    if imgui.MenuItem("Sprite Viewer") then
      self.showAnimViewer = not self.showAnimViewer
    end
  end
  
  if self.showAnimViewer then
    imgui.Begin("Animation Viewer")
    imgui.Image(self.animViewerCanvas, self.animViewerCanvas:getWidth(), self.animViewerCanvas:getHeight())
    imgui.End()
  end
  
end

function ContentViewer:draw()
  love.graphics.setCanvas(self.animViewerCanvas)
  love.graphics.clear(204 / 255, 204 / 255, 204 / 255)
  love.graphics.print('hello world')
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