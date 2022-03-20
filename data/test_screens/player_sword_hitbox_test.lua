local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local Direction4 = require 'engine.enums.direction4'

local PlayerSwordHitboxTest  = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.player = nil
  end
}

function PlayerSwordHitboxTest:enter(prev, ...)
  require('lib.tick').timescale = .3
  self.player = Player {
    name = 'player',
    x = 24,
    y = 24
  }
  self.sword = Sword()
  self.sword.useButtons = { 'b' }
  print(self.sword.hitbox)
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
end

function PlayerSwordHitboxTest:update(dt)
  self.player:update(dt)
end

function PlayerSwordHitboxTest:draw()
  monocle:begin()
  self.player:draw()
  if self.sword:isVisible() then
    self.sword:draw()
  end
  self.sword:debugDraw()
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  monocle:finish()
end

return PlayerSwordHitboxTest