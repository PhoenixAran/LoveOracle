local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Item = require 'engine.items.item'

---@class ItemEquipment : Item
---@field equipped boolean
local ItemEquipment = Class { __includes = Item,
  init = function(self, args)
    Item.init(self, args)
    self.equipped = false
  end
}

function ItemEquipment:getType()
  return 'item_equipment'
end

function ItemEquipment:isEquippable()
  return true
end

function ItemEquipment:isEquipped()
  return self.isEquipped
end

function ItemEquipment:isUsable()
  return false
end

function ItemEquipment:equip()
  if not self.equipped then
    self.equipped = true
    self:onEquip()
  end
end

function ItemEquipment:unequip()
  if self.equipped then
    self.equipped = false
    self:onUnequip()
  end
end

function ItemEquipment:onEquip()

end

function ItemEquipment:onUnequip()

end


return ItemEquipment