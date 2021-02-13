local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local BaseScreen = require 'engine.screens.base_screen'

local SpriteViewer = require 'engine.screens.slab_modules.sprite_viewer'
local TilesetViewer = require 'engine.screens.slab_modules.tileset_viewer'
local ContentControl = require 'engine.control.content_control'
local ContentViewer = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.spriteViewer = nil
    self.tilesetViewer = nil
  end
}

function ContentViewer:enter(prev, ...)
  self.spriteViewer = SpriteViewer()
  self.spriteViewer:initialize()
  self.tilesetViewer = TilesetViewer()
  self.tilesetViewer:initialize()
end

function ContentViewer:update(dt)
  Slab.Update(dt)
  
  Slab.BeginWindow('content-controller', { Title = 'Content Control'})
  if Slab.Button('Reload Content') then
    ContentControl.unloadContent()
    ContentControl.buildContent()
    self.spriteViewer:initialize()
    self.tilesetViewer:initialize()
  end
  Slab.EndWindow()
  self.spriteViewer:update(dt)
  self.tilesetViewer:update(dt)
end

function ContentViewer:draw()
  self.spriteViewer:draw()
  self.tilesetViewer:draw()
  Slab.Draw()
end

return ContentViewer