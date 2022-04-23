local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Entities = require 'engine.entities.entities'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local Slab = require 'lib.slab'
local PaletteBank = require 'engine.utils.palette_bank'
local monocle = require('engine.singletons').monocle

local PlayerPaletteTest = Class { __includes = BaseScreen,
  init = function(self)
    self.player = nil
    self.entities = Entities(self)
    
    -- IMGUI palette stuff
    self.paletteChoice = 1
    self.paletteKeys = {
        'Default',
        'Defense',
        'Attack'
    }
    self.palettes = {
      nil,
      PaletteBank.getPalette('player_defense_tunic'):getShader(), 
      PaletteBank.getPalette('player_attack_tunic'):getShader()
    }
  end
}

function PlayerPaletteTest:enter(prev, ...)
  self.player = Player('player', true, true, { x = 24, y = 24, w = 16, h = 16 })
  self.sword = Sword('player_sword')
  self.sword.useButtons = { 'b' }
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
  self.entities:setPlayer(self.player)
end

function PlayerPaletteTest:update(dt)
  Slab.Update(dt)
  Slab.BeginWindow('PaletteChooser', { Title = 'Palette Chooser' })
  for i = 1, #self.palettes, 1 do
    if Slab.RadioButton(self.paletteKeys[i] .. ' Tunic', {Index = i, SelectedIndex = self.paletteChoice}) then
      self.paletteChoice = i
    end
  end
  self.entities:update(dt)
  Slab.EndWindow()
end

function PlayerPaletteTest:draw()
  monocle:begin()
  love.graphics.setShader(self.palettes[self.paletteChoice])
  self.player:draw()
  love.graphics.setShader()
  if self.sword:isVisible() then 
    self.sword:draw()
  end
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  monocle:finish()
  
  Slab.Draw()
end

return PlayerPaletteTest