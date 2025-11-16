local Projectile = require 'engine'
local Class = require 'lib.class'

---@class BoneProjectile : Projectile
local BoneProjectile = Class { __includes = Projectile,
  init = function(self, owner)
    Projectile.init(self)


  end
}

return BoneProjectile

