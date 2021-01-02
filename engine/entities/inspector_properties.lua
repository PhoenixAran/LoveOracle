local Class = require 'lib.class'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'

local PropertyType = { 
  Int = 1, 
  Float = 2,
  String = 3,
  IntRange = 4,
  FloatRange = 5,
  ReadOnly = 6
}

local PropertyMode = { 
  Func = 1,
  Direct = 2
}

-- friend type
local Property = Class {
  init = function(self, source, label, propType)
    self.propType = propType
    self.source = source
    
    self.label = label
    self.mode = nil
    self.isObjectFuncs = nil
    self.getFunc = nil
    self.setFunc = nil
    self.propName = nil
    
    self.min = 0
    self.max = 0
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
  self.mode = PropertyType.FloatRange
  self.min = min
  self.max = max
end

function Property:setIntRange(min, max)
  self.mode = PropertyType.IntRange
  self.min = min
  self.max = max
end

function Property:setValue(value)
  assert(not self.propType == PropertyType.ReadOnly)
  if self.mode == PropertyMode.Func then
    if self.isObjectFuncs then
      self.setFunc(self.source, value)
    else
      self.setFunc(value)
    end
  else
    self.source[self.propName] = value
  end
end

function Property:getValue(value)
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

-- export type
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

function InspectorProperties:addReadOnly(label, getFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.ReadOnly)
  setReadOnlyAccessor(property, getFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addInt(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Int)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addFloat(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.Float)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

function InspectorProperties:addString(label, getFunc, setFunc, isObjectFuncs)
  local property = Property(self.source, label, PropertyType.String)
  setAccessors(property, getFunc, setFunc, isObjectFuncs)
  addProperty(self, property)
end

-- export PropertyType enum
InspectorProperties.PropertyType = PropertyType

-- TODO int range, float range, string list

return InspectorProperties