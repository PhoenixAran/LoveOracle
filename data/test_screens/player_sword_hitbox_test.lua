local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local tick = require 'lib.tick'
local console = require 'lib.console'
local DisplayHandler = require 'engine.display_handler'
local Input = require('engine.singletons').input

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

function PlayerSwordHitboxTest:update()
  console.update(love.time.dt)
  if not console.active then
    Input:update(love.time.dt)
    self.player:update()
  end
end

function PlayerSwordHitboxTest:draw()
  DisplayHandler.push()
  self.player:draw()
  self.player:debugDraw()
  self.sword:debugDraw()
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  DisplayHandler.pop()
  love.graphics.setFont(console.font)
  console.draw()
end

return PlayerSwordHitboxTest