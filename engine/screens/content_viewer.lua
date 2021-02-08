local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local BaseScreen = require 'engine.screens.base_screen'

local SpriteViewer = require 'engine.screens.slab_modules.sprite_viewer'
local TilesetViewer = require 'engine.screens.slab_modules.tileset_viewer'

local ContentViewer = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.spriteViewer = nil
    self.tilesetViewer = nil
  end
}

function ContentViewer:enter(prev, ...)
  self.spriteViewer = SpriteViewer()
  self.tilesetViewer = TilesetViewer()
end

function ContentViewer:update(dt)
  Slab.Update(dt)
  self.spriteViewer:update(dt)
  self.tilesetViewer:update(dt)
end

function ContentViewer:draw()
  Slab.Draw()
end

return ContentViewer