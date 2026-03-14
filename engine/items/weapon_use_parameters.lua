local Class = require 'lib.class'

-- determines if item can be used
---@class WeaponUseParameters
---@field twoHanded boolean
---@field usableWhileJumping boolean
---@field usableWithSword boolean
---@field usableWhileInHole boolean
local WeaponUseParameters = Class {
  init = function(self)
    self.twoHanded = false
    -- usable while jumping
    self.usableWhileJumping = false
    -- usable while holding a sword
    self.usableWithSword = false
    -- usable while gravitating towards hole
    self.usableWhileInHole = false
  end
}

function WeaponUseParameters:getType()
  return 'item_use_parameters'
end

return WeaponUseParameters