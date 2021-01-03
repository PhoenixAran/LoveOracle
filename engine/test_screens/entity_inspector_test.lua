local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local Player = require 'engine.player.player'
local Sword = require 'engine.items.weapons.item_sword'
local Slab = require 'lib.slab'
local PropertyType = require('engine.entities.inspector_properties').PropertyType

-- TODO: wrap EntityInspector in a class / method so all screens can use it

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
    local slabId = self.player:getName() .. property:getLabel()
    -- Draw the property name
    Slab.Text(property:getLabel())
    -- Then draw the necessary input elements
    if propType == PropertyType.String then
      local slabArgs = { 
        Align = 'left',
        Text = tostring(property:getValue()), 
        ReadOnly = property:isReadOnly(),
      }
      if Slab.Input(slabId, slabArgs) then
        property:setValue(Slab.GetInputText())
      end
    elseif propType == PropertyType.Int then
      local slabArgs = { 
        Align = 'left',
        Text = tostring(property:getValue()),
        ReadOnly = property:isReadOnly(),
        NumbersOnly = true
      }
      if Slab.Input(slabId, slabArgs) then
        property:setValue(math.floor(Slab.GetInputNumber()))
      end

    elseif propType == PropertyType.Float then
      local slabArgs = { 
        Align = 'left',
        Text = tostring(property:getValue()),
        ReadOnly = property:isReadOnly(),
        NumbersOnly = true
      }
      if Slab.Input(slabId, slabArgs) then
        property:setValue(Slab.GetInputNumber())
      end
    elseif propType == PropertyType.Vector2 then
      local vx, vy = property:getValue()
      local slabArgs = { 
        Align = 'left',
        Text = tostring(vx),
        ReadOnly = property:isReadOnly(),
        NumbersOnly = true,
        ReturnOnText = false
      }
      if Slab.Input(slabId .. 'x', slabArgs) then
        local x, y = property:getValue()
        property:setValue(Slab.GetInputNumber(), y)
      end
      slabArgs.Text = tostring(vy)
      Slab.SameLine()
      if Slab.Input(slabId .. 'y', slabArgs) then
        local x, y = property:getValue()
        property:setValue(x, Slab.GetInputNumber())
      end
    elseif propType == PropertyType.Vector2I then
      local vx, vy = property:getValue()
      local slabArgs = {
        Align = 'left',
        Text = tostring(vx),
        ReadOnly = property:isReadOnly(),
        NumbersOnly = true, 
        ReturnOnText = false
      }
      if Slab.Input(slabId .. 'x', slabArgs) then
        local x, y = property:getValue()
        property:setValue(math.floor(Slab.GetInputNumber()), y)
      end
      slabArgs.Text = tostring(vy)
      Slab.SameLine()
      if Slab.Input(slabId .. 'y', slabArgs) then
        local x, y = property:getValue()
        property:setValue(x, math.floor(Slab.GetInputNumber()))
      end
    end
  end
  Slab.EndWindow()
  self.player:update(dt)
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