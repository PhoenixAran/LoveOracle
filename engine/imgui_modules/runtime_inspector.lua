local imgui = require('imgui')
local PropertyType = require('engine.entities.inspector_properties').PropertyType

---@type Entity
local entity = nil
local cachedProps = {} 
local RuntimeInspector = { }
local isWindowOpen = true

function RuntimeInspector.setup(newEntity)
  entity = newEntity
  cachedProps = entity:getInspectorProperties()
  isWindowOpen = true
end

---@param property Property
local function renderProperty(property)
  local MAX_LENGTH = 10000
  local propType = property:getPropertyType()
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
    local value = imgui.InputInt(property:getLabel(), property:getValue())
    if readOnlyFlags == nil then
      property:setValue(value)
    end
  elseif propType == PropertyType.Float then
    local value = imgui.InputFloat(property:getLabel(), property:getValue())
    if readOnlyFlags == nil then
      property:setValue(value)
    end
  elseif propType == PropertyType.Vector2 then
    local x, y = property:getValue()
    local newX = imgui.InputFloat(property:getLabel() .. 'X', x)
    local newY = imgui.InputFloat(property:getLabel() .. 'Y', y)
    if readOnlyFlags == nil then
      property:setValue(newX, newY)
    end
  elseif propType == PropertyType.Vector2i then
    local x, y = property:getValue()
    local newX = imgui.InputInt(property:getLabel() .. 'X', x)
    local newY = imgui.InputInt(property:getLabel() .. 'Y', y)
    if readOnlyFlags == nil then
      property:setValue(newX, newY)
    end
  end
end

local function close()
  local singleton = require 'engine.singletons'
  local lume = require 'lib.lume'
  lume.remove(singleton.imguiModules, RuntimeInspector)
end

function RuntimeInspector.draw()
  assert(entity ~= nil and cachedProps ~= nil, 'Runtime inspector draw called without valid setup')
  isWindowOpen = imgui.Begin(('Entity Inspector - %s'):format(entity.name), true, "ImGuiWindowFlags_MenuBar")
  if not isWindowOpen then
    imgui.End()
    close()
  end
  local firstGroup = true
  for groupName, elem in pairs(cachedProps.properties) do
    if elem.getType then
      renderProperty(elem)
    else
      local currentGroupNameDrawn = false
      for _, prop in ipairs(elem) do
        if not currentGroupNameDrawn then
          imgui.Text(groupName)
          currentGroupNameDrawn = true
        end
        renderProperty(prop)
        if firstGroup then
          firstGroup = false
        elseif prop == elem[#elem] then
          imgui.Separator()
        end
      end
    end
  end
  imgui.End()
end

return RuntimeInspector