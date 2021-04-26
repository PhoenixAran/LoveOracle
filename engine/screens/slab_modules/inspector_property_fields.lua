local Slab = require 'lib.slab'
local PropertyType = require('engine.entities.inspector_properties').PropertyType

-- assumes window has already been started
function makePropertyFields(props, idPrefix)
  for _, property in ipairs(props.properties) do
    local propType = property:getPropertyType()
    local slabId = idPrefix .. property:getLabel()
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
    elseif propType == PropertyType.Vector2i then
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

return {
  makePropertyFields = makePropertyFields
}