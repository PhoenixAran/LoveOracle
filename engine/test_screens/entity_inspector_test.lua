local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Entities = require 'engine.entities.entities'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local EntityInspector = require 'engine.screens.slab_modules.entity_inspector'
local Slab = require 'lib.slab'
local PropertyType = require('engine.entities.inspector_properties').PropertyType
local DisplayHandler = require 'engine.display_handler'

local EntityInspectorTest = Class { __includes = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    self.player = nil
    self.entities = Entities(self)
    self.entityInspector = EntityInspector(self.entities)
  end
}

function EntityInspectorTest:enter(prev, ...)
  self.player = Player({name = 'player', x = 24, y = 24, w = 16, h = 16 })
  self.player:initTransform()
  self.sword = Sword()
  self.sword.useButtons = { 'b' }
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
  self.entities:setPlayer(self.player)
end

function EntityInspectorTest:update()
  Slab.Update(love.time.dt)
  self.entities:update()
  self.entityInspector:update()
end

function EntityInspectorTest:draw()
  DisplayHandler.push()
  self.player:draw()
  --self.player:debugDraw()
  if self.sword:isVisible() then 
    self.sword:draw()
  end
  self:drawFPS()
  self:drawMemory()
  self:drawVersion()
  DisplayHandler.pop()
  Slab.Draw()
end

return EntityInspectorTest