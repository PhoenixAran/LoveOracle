local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local Direction4 = require 'engine.enums.direction4'
local Singletons = require 'engine.singletons'
local DisplayHandler = Singletons.DisplayHandler
local Input = require('engine.singletons').input

local PlayerPlayground = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.player = nil
  end
}

function PlayerPlayground:enter(prev, ...)
  self.player = Player({
    name = 'player',
    x = 24,
    y = 24
  })
  self.player:initTransform()
  self.sword = Sword()
  self.sword.useButtons = { 'b' }
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
end

function PlayerPlayground:update(dt)
  Input:update(dt)
  self.player:update(dt)
end

function PlayerPlayground:draw()
  monocle:begin()
  self.player:draw()
  if self.sword:isVisible() then
    self.sword:draw()
  end
  self.sword:debugDraw()
  self.player:debugDraw()
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  monocle:finish()
end

return PlayerPlayground