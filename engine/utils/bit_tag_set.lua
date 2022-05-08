local Class = require 'lib.class'
local bit = require 'bit'

local BitTag = Class {
  init = function(self, id, value, name)
    self.id = id
    self.value = value
    self.name = name
    self.enumMap = nil
  end
}

function BitTag:getType()
  return 'bit_tag'
end

local BitTagSet = Class {
  init = function(self, setName)
    self.setName = setName
    self.totalTags = 0
    self.byId = { }
    self.byName = { }
  end
}

function BitTagSet:getType() 
  return 'bit_tag_set'
end

function BitTagSet:makeTag(name)
  assert(self.totalTags <= 32, 'Maximum tag limit of 32 exceeded for tag set "' .. self.setName .. '"')
  name = string.lower(name)
  local id = self.totalTags
  local value = bit.lshift(1, self.totalTags)
  local bitTag = BitTag(id, value, name)
  self.byId[id] = bitTag
  self.byName[name] = bitTag
  self.totalTags = self.totalTags + 1
end

function BitTagSet:makeTags(names)
  for _, v in ipairs(names) do
    self:makeTag(v)
  end
end

function BitTagSet:get(str)
  str = string.lower(str)
  return self.byName[str]
end

function BitTagSet:makeEnumMap(map)
  self.enumMap = { }
  for k, v in pairs(map) do
    local bitTag = self:get(v)
    assert(bitTag, 'No tag with string id ' .. tostring(v))
    self.enumMap[k] = bitTag.value
  end
end

return BitTagSet