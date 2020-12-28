local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local Slab = require 'lib.slab'

local PlayerPlayground = Class { __includes = BaseScreen,
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
  Slab.Initialize(args)
end

function PlayerPlayground:update(dt)
  Slab.Update(dt)
	Slab.BeginWindow('MyFirstWindow', {Title = "My First Window"})
	Slab.Text("Hello World")
	Slab.EndWindow()
  self.player:update(dt)
end

function PlayerPlayground:draw()
  monocle:begin()
  self.player:draw()
  if self.sword:isVisible() then 
    self.sword:draw()
  end
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  monocle:finish()
  Slab.Draw()
end

return PlayerPlayground