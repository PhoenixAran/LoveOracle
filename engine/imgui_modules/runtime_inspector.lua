local imgui = require('imgui')
local PropertyType = require('engine.entities.inspector_properties').PropertyType

---@type Entity
local entity = nil
local cachedProps = {} 
local RuntimeInspector = { }

function RuntimeInspector.setup(newEntity)
  entity = newEntity
  cachedProps = entity:getInspectorProperties()
end

function RuntimeInspector.draw()
  local MAX_LENGTH = 10000
  assert(entity ~= nil and cachedProps ~= nil, 'Runtime inspector draw called without valid setup')
  imgui.NewFrame()
  imgui.Begin(('Entity Inspector %s'):format(entity.name))
  for _, property in ipairs(cachedProps.properties) do
    local propType = property:getPropertyType()
    if propType == PropertyType.Separator then
      -- separator. just for visual organization
      imgui.Seperator(property:getLabel())
    else 
      local readOnlyFlags = nil
      if property:isReadOnly() then
        readOnlyFlags = "ImGuiTextFlags_ReadOnly"
      end
      -- its an actual property type
      if propType == PropertyType.String then
        local value = imgui.InputText(property:getLabel(), property:getValue(), MAX_LENGTH, readOnlyFlags)
        if readOnlyFlags == nil then
          property:setValue(value)
        end
      elseif propType == PropertyType.Int then
        if readOnlyFlags then
          imgui.BeginDisabled()
        end
        local value = imgui.InputInt(property:getLabel(), property:getValue())
        if readOnlyFlags then
          imgui.EndDisabled()
        else
          property:setValue(value)
        end
      elseif propType == PropertyType.Float then
        if readOnlyFlags then
          imgui.BeginDisabled()
        end
        local value = imgui.InputFloat(property:getLabel(), property:getValue())
        if readOnlyFlags then
          imgui.EndDisabled()
        else
          property:setValue(value)
        end
      elseif propType == PropertyType.Vector2 then
        local x, y = property:getValue()
        if readOnlyFlags then
          imgui.BeginDisabled()
        end
        local valueX = imgui.InputFloat(property:getLabel(), x)

        if readOnlyFlags then
          imgui.EndDisabled()
          imgui.BeginDisabled()
        end
        imgui.PushItemWidth(-1)
        local valueY = imgui.InputFloat('', y)
        imgui.PopItemWidth()

        if readOnlyFlags then
          imgui.EndDisabled()
        else
          property:setValue(valueX, valueY)
        end
      elseif propType == PropertyType.Vector2i then
        local x, y = property:getValue()
        if readOnlyFlags then
          imgui.BeginDisabled()
        end
        local valueX = imgui.InputInt(property:getLabel(), x)

        if readOnlyFlags then
          imgui.EndDisabled()
          imgui.BeginDisabled()
        end
        imgui.PushItemWidth(-1)
        local valueY = imgui.InputInt('', property:getLabel(), y)
        imgui.PopItemWidth()

        if readOnlyFlags then
          imgui.EndDisabled()
        else
          property:setValue(valueX, valueY)
        end
      end
    end

  end
end

return RuntimeInspector