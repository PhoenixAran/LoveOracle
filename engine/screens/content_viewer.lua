local Class = require 'lib.class'
local lume = require 'lib.lume'
local lurker = require 'lib.lurker'
local Slab = require 'lib.slab'
local BaseScreen = require 'engine.screens.base_screen'

local SpriteViewer = require 'engine.screens.slab_modules.sprite_viewer'
local TilesetViewer = require 'engine.screens.slab_modules.tileset_viewer'
local ContentControl = require 'engine.control.content_control'

local PaletteBank = require 'engine.utils.palette_bank'
local AssetManager = require 'engine.utils.asset_manager'
local SpriteBank = require 'engine.utils.sprite_bank'
local TilesetBank = require 'engine.utils.tileset_bank'
local Inspect = require 'lib.inspect'
local ContentViewer = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.spriteViewer = nil
    self.tilesetViewer = nil
    self.error = nil
  end
}

function ContentViewer:enter(prev, ...)
  self.spriteViewer = SpriteViewer()
  self.spriteViewer:initialize()
  self.tilesetViewer = TilesetViewer()
  self.tilesetViewer:initialize()
end

function ContentViewer:reloadContent()
  ContentControl.unloadContent()
  lurker.scan()
  ContentControl.buildContent()
end

function ContentViewer:update(dt)
  Slab.Update(dt)
  Slab.BeginWindow('content-controller', { Title = 'Content Control'})
  if Slab.Button('Reload Content', {Tooltip = 'Look at the console window to check for errors'}) then
    self:reloadContent()
    self.spriteViewer:initialize()
    self.tilesetViewer:initialize()
  end
  Slab.EndWindow()
  self.spriteViewer:update()
  self.tilesetViewer:update()

end

function ContentViewer:draw()
  self.spriteViewer:draw()
  self.tilesetViewer:draw()
  Slab.Draw()
end

return ContentViewer