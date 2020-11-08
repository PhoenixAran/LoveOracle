local Class = require 'lib.class'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'

local PlayerPlayground = Class {
  init = function(self)
    self.player = nil
  end
}

function PlayerPlayground:enter(prev, ...)
  self.player = Player(true, true, { x = 24, y = 24, w = 16, h = 16 })
  local sword = Sword()
  sword.useButtons = { 'b' }
  self.player:equipItem(sword)
end

function PlayerPlayground:update(dt)
  self.player:update(dt)
end

function PlayerPlayground:draw()
  self.player:draw()
end

return PlayerPlayground