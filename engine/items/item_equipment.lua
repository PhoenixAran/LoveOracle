local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Item = require 'engine.items.item'
local ItemUseParameters = require 'engine.items.item_use_parameters'

---@class ItemEquipment : Item
---@field useParameters ItemUseParameters
local ItemEquipment = Class { __includes = Item,
  init = function(self, args)
    Item.init(self, args)
    self.useParameters = ItemUseParameters()
    -- Initialization code here
  end
}

function ItemEquipment:getType()
  return 'item_equipment'
end

function ItemEquipment:isEquippable()
  return true
end

function ItemEquipment:isTwoHanded()
  return self.useParameters.twoHanded
end

return ItemEquipment