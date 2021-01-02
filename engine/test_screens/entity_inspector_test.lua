local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local Slab = require 'lib.slab'
local PropertyType = require('engine.entities.inspector_properties').PropertyType

local EntityInspectorTest = Class { __includes = BaseScreen,
  init = function(self)
    self.player = nil
  end
}

function EntityInspectorTest:enter(prev, ...)
  self.player = Player('player', true, true, { x = 24, y = 24, w = 16, h = 16 })
  self.sword = Sword('player_sword')
  self.sword.useButtons = { 'b' }
  self.player:equipItem(self.sword)
  self.sword:setVisible(false)
  Slab.Initialize(args)
end

function EntityInspectorTest:update(dt)
  Slab.Update(dt)
  Slab.BeginWindow('EntityInspector', { Title = 'Entity Inspector'})
  local props = self.player:getInspectorProperties()
  for _, property in ipairs(props.properties) do
    local propType = property:getPropertyType()
    if propType == PropertyType.ReadOnly then
      Slab.Text(property:getLabel())
      Slab.Input(self.player:getName() .. property:getLabel() , { Text = tostring(property:getValue()),  ReadOnly = true, Align = 'left' })
    end
  end
  Slab.EndWindow()
  self.player:update(dt)
end

function EntityInspectorTest:draw()
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

return EntityInspectorTest