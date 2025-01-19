local Class = require 'lib.class'
local lume = require 'lib.lume'

local PropertyType = {
  Int = 'int',
  Float = 'float',
  String = 'string',
  IntRange = 'int_range',
  FloatRange = 'float_range',
  Vector2 = 'vector2',
  Vector2I = 'vector2i',
  Rect = 'rect',

  -- TODO
  Vector2iList = 'vector2i_list',

  -- used to organize properties in entity inspector
  Separator = 'separator',
}

local PropertyMode = {
  Func = 1,
  Direct = 2
}

---@class Property
---@field source table
---@field label string
---@field propType string
---@field readOnly boolean
---@field mode integer
---@field isObjectFuncs boolean
---@field getFunc function
---@field setFunc function
---@field propName string
---@field min number
---@field max number
---@field argumentHolder any[]
local Property = Class {
  init = function(self, source, label, propType, readOnly)
    self.propType = propType
    self.source = source

    if readOnly == nil then readOnly = false end
    self.readOnly = readOnly
    self.label = label
    self.mode = nil
    self.isObjectFuncs = nil
    self.getFunc = nil
    self.setFunc = nil
    self.propName = nil

    self.min = 0
    self.max = 0
    self.argumentHolder = { }
  end
}

function Property:setAccessorFuncs(getFunc, setFunc, isObjectFuncs)
  if isObjectFuncs == nil then
    isObjectFuncs = true
  end
  self.isObjectFuncs = isObjectFuncs
  self.propName = nil
  self.mode = PropertyMode.Func
  self.getFunc = getFunc
  if not self.readOnly then
    self.setFunc = setFunc
  end
end

function Property:setPropName(name)
  self.setFunc = nil
  self.getFunc = nil
  self.mode = PropertyMode.Direct
  self.propName = name
end

function Property:setFloatRange(min, max)
  self.propType = PropertyType.FloatRange
  self.min = min
  self.max = max
end

function Property:setIntRange(min, max)
  self.propType = PropertyType.IntRange
  self.min = min
  self.max = max
end

function Property:setValue(...)
  assert(not self.readOnly)
  if self.mode == PropertyMode.Func then
    if self.isObjectFuncs then
      lume.push(self.argumentHolder, self.source)
      lume.push(self.argumentHolder, ...)
      self.setFunc(unpack(self.argumentHolder))
    else
      lume.push(self.argumentHolder,...)
      self.setFunc(unpack(self.argumentHolder))
    end
    lume.clear(self.argumentHolder)
  else
    self.source[self.propName] = select(1, ...)
  end
end

function Property:getValue()
  if self.mode == PropertyMode.Func then
    if self.isObjectFuncs then
      return self.getFunc(self.source)
    else
      return self.getFunc()
    end
  else
    return self.source[self.propName]
  end
end

function Property:getLabel()
  return self.label
end

function Property:getPropertyType()
  return self.propType
end

function Property:isReadOnly()
  return self.readOnly
end

---@class InspectorProperties
---@field source table
---@field properties Property[]
local InspectorProperties = Class {
  init = function(self, source)
    self.source = source
    self.properties = { }
  end
}

local function addProperty(inspectorProperties, property)
  lume.push(inspectorProperties.properties, property)
end

local function setAccessors(property, getFunc, setFunc, isObjectFuncs)
  if setFunc == nil then
    local propName = getFunc
    assert(type(getFunc) == 'string')
    property:setPropName(propName)
  else
    assert(type(getFunc) == 'function')
    assert(type(setFunc) == 'function')
    property:setAccessorFuncs(getFunc, setFunc, isObjectFuncs)
  end
end

local function setReadOnlyAccessor(property, getFunc, isObjectFuncs)
  if type(getFunc) == 'string' then
    local propName = getFunc
    property:setPropName(propName)
  else
    assert(type(getFunc) == 'function')
    property:setAccessorFuncs(getFunc, nil, isObjectFuncs)
  end
end

function InspectorProperties:addInt(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Int)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

---
function InspectorProperties:addReadOnlyInt(label, getFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Int, true)
  setReadOnlyAccessor(property, getFunc, isObjectFuncs)
  addProperty(self, property)
end

-- FLOAT
function InspectorProperties:addFloat(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Float)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addReadOnlyFloat(label, getFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Float, true)
  setReadOnlyAccessor(property, getFunc, isObjectFuncs)
  addProperty(self, property)
end

-- STRING
function InspectorProperties:addString(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.String)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addReadOnlyString(label, getFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.String, true)
  setReadOnlyAccessor(property, getFunc, isObjectFuncs)
  addProperty(self, property)
end

-- VECTOR2
function InspectorProperties:addVector2(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Vector2)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addReadOnlyVector2(label, getFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Vector2, true)
  setAccessors(property, getFunc, isObjectFuncs)
  addProperty(self, property)
end

-- VECTOR2I
function InspectorProperties:addVector2i(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Vector2I)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addReadOnlyVector2i(label, getFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Vector2I, true)
  setReadOnlyAccessor(property, getFunc, isObjectFuncs)
  addProperty(self, property)
end

-- RECT
function InspectorProperties:addRect(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Rect)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addReadOnlyRect(label, getFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Rect, true)
  setReadOnlyAccessor(property, getFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addSeparator(name)
  local property = Property(self.source, name, PropertyType.Seperator, true)
  addProperty(self, property)
end

function InspectorProperties:count()
  return lume.count(self.properties)
end

-- export PropertyType enum
InspectorProperties.PropertyType = PropertyType

return InspectorProperties