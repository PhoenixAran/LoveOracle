local Class = require 'lib.class'
local lume = require 'lib.lume'
local lurker = require 'lib.lurker'
local Slab = require 'lib.slab'
local BaseScreen = require 'engine.screens.base_screen'

local SpriteViewer = require 'engine.screens.slab_modules.sprite_viewer'

local ContentControl = require 'engine.utils.content_control'
local PaletteBank = require 'engine.utils.palette_bank'
local AssetManager = require 'engine.utils.asset_manager'
local SpriteBank = require 'engine.utils.sprite_bank'
local Inspect = require 'lib.inspect'
local ContentViewer = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)   
    self.spriteViewer = nil   
    self.showSpriteViewer = false
  end
}

function ContentViewer:enter(prev, ...)
  self.spriteViewer = SpriteViewer()
  self.spriteViewer:initialize()
end

function ContentViewer:reloadContent()
  ContentControl.unloadContent()
  lurker.scan()
  ContentControl.buildContent()
end

function ContentViewer:update(dt)
  Slab.Update(dt)
  if Slab.BeginMainMenuBar() then
    if Slab.BeginMenu("View") then
      if Slab.MenuItemChecked("Sprite Viewer", self.showSpriteViewer) then
        self.showSpriteViewer = not self.showSpriteViewer
      end
      if Slab.MenuItemChecked("Tileset Viewer", self.showTilesetViewer) then
        self.showTilesetViewer = not self.showTilesetViewer
      end
      if Slab.MenuItemChecked("Tileset Theme Viewer", self.showTilesetThemeViewer) then
        self.showTilewsetThemeViewer = not self.showTilesetThemeViewer
      end
      Slab.EndMenu()
    end
    if Slab.Button('Reload Content') then
      print('Reloading content...')
      local startTime = love.timer.getTime()
      self:reloadContent()
      self.spriteViewer:initialize()
      local endTime = love.timer.getTime()
      print('Reload complete. Elapsed time: ', (endTime - startTime) * 1000, ' ms')
    end
    Slab.EndMainMenuBar()
  end
  if self.showSpriteViewer then
    self.spriteViewer:update(dt)
  end
end

function ContentViewer:draw()
  self.spriteViewer:draw()
  Slab.Draw()
end

return ContentViewer