local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local ItemWeapon = require 'engine.items.weapons.item_weapon'
local CollisionTag = require 'engine.enums.collision_tag'
local Direction4 = require 'engine.enums.direction4'
local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap

-- TODO implmement

---@class Item : ItemWeapon
local ItemBoomerang = Class { __includes = ItemWeapon,
  init = function(self, args)
    ItemWeapon.init(self, args)
  end
}

return ItemBoomerang