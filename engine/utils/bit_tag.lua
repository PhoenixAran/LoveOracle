local Class = require 'lib.class'
local bit = require 'bit'

local totalTags = 0
local byId =  { }
local byName = { }

-- Used for declaring Physics Layer Flags
local BitTag = Class {
  init = function(self, name)
    assert(totalTags <= 32, 'Maximum tag limit of 32 exceeded ' )
    name = string.lower(name)
    self.id = totalTags
    self.value = bit.lshift(1, totalTags)
    
    byId[self.id] = self
    byName[name] = self
    
    totalTags = totalTags + 1
  end
}

function BitTag:getType()
  return 'bit_tag'
end

function BitTag.get(str)
  str = string.lower(str)
  return byName[str]
end

return BitTag