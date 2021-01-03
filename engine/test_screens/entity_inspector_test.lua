local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Entities = require 'engine.entities.entities'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local EntityInspector = require 'engine.screens.slab.entity_inspector'
local Slab = require 'lib.slab'
local PropertyType = require('engine.entities.inspector_properties').PropertyType


local EntityInspectorTest = Class { __includes = BaseScreen,
  init = function(self)
    self.player = nil
    self.entities = Entities(self)
    self.entityInspector = EntityInspector(self.entities)
  end
}

function EntityInspectorTest:enter(prev, ...)
  self.player = Player('player', true, true, { x = 24, y = 24, w = 16, h = 16 })
  self.sword = Sword('player_sword')
  self.sword.useButtons = { 'b' }
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
  self.entities:setPlayer(self.player)
  Slab.Initialize()
end

function EntityInspectorTest:update(dt)
  Slab.Update(dt)
  self.entities:update(dt)
  self.entityInspector:update(dt)
end

function EntityInspectorTest:draw()
  monocle:begin()
  self.player:draw()
  self.player:debugDraw()
  if self.sword:isVisible() then 
    self.sword:draw()
  end
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  monocle:finish()
  Slab.Draw()
end

return EntityInspectorTest