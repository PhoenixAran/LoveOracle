local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local tick = require 'lib.tick'
local console = require 'lib.console'

local PlayerSwordHitboxTest  = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.player = nil
  end
}

function PlayerSwordHitboxTest:enter(prev, ...)
  self.player = Player {
    name = 'player',
    x = 24,
    y = 24
  }
  self.player:initTransform()
  self.sword = Sword()
  self.sword.useButtons = { 'b' }
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
end

function PlayerSwordHitboxTest:update(dt)
  if self.consoleEnabled then
    console.update(dt)
  end
  if not self.consoleEnabled then
    if love.keyboard.isDown('u') then
      tick.timescale = .3
    else
      tick.timescale = 1
    end
    self.player:update(dt)
  end
end

function PlayerSwordHitboxTest:draw()
  monocle:begin()
  self.player:draw()
  self.sword:debugDraw()
  if self.consoleEnabled then
    love.graphics.print('Console Enabled. Press F8!')
  end
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  monocle:finish()
  if self.consoleEnabled then
    console.draw()
  end
end

return PlayerSwordHitboxTest