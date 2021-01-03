local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local PropertyType = require('engine.entities.inspector_properties').PropertyType

local EntityInspector = Class { __includes = SignalObject,
  init = function(self, entities)
    self.entities = entities
    self.currentEntity = nil
    
    self.searchText = ''
  end
}

function EntityInspector:update(dt)
  Slab.BeginWindow('EntityInspector', { Title = 'Entity Inspector' })
  Slab.Text('Entity Search')
  if Slab.Input('EntitySearch', { Text = self.searchText, ReturnOnText = true}) then
    self.searchText = Slab.GetInputText()
  end
  Slab.Separator()
  self.currentEntity = self.entities:getByName(self.searchText:gsub("^%s*(.-)%s*$", "%1"))
  if self.currentEntity then
    local props = self.currentEntity:getInspectorProperties()
    for _, property in ipairs(props.properties) do
      local propType = property:getPropertyType()
      local slabId = self.currentEntity:getName() .. property:getLabel()
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
  end
  Slab.EndWindow()
end

return EntityInspector