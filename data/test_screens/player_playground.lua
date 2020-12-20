local Class = require 'lib.class'
local Slab = require 'lib.slab'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'

local PlayerPlayground = Class {
  init = function(self)
    self.player = nil
  end
}

function PlayerPlayground:enter(prev, ...)
  self.player = Player(true, true, { x = 24, y = 24, w = 16, h = 16 })
  self.sword = Sword()
  self.sword.useButtons = { 'b' }
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
end

function PlayerPlayground:update(dt)
  self.player:update(dt)
end

function PlayerPlayground:draw()
  monocle:begin()
  self.player:draw()
  if self.sword:isVisible() then 
    self.sword:draw()
  end
  monocle:finish()
end

return PlayerPlayground