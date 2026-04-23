-- register items into item bank in this file
local ItemBank = require 'engine.banks.item_bank'


-- sword item
local swordData = ItemBank.createItemData('item_sword')
swordData:setMenuSprite({'icon_sword_1', 'icon_sword_2', 'icon_sword_3'})
swordData:setItemType(1, require('engine.items.weapons.item_sword'))
-- todo uncomment below when item_sword takes levels into account
-- swordData:setItemType(2, require('engine.items.weapons.item_sword'))
-- swordData:setItemType(3, require('engine.items.weapons.item_sword'))
swordData:setEquippable(true)
swordData:setButtonSlotItem(true)
ItemBank.registerItem(swordData)

-- shield
local shieldData = ItemBank.createItemData('item_shield')
shieldData:setEquippable(true)
shieldData:setItemType(1, require('engine.items.weapons.item_shield'))
-- todo uncomment below when item_shield takes levels into account
-- shieldData:setItemType(2, require('engine.items.equipment.item_shield'))
-- shieldData:setItemType(3, require('engine.items.equipment.item_shield'))
shieldData:setButtonSlotItem(true)
ItemBank.registerItem(shieldData)

local boomerang = ItemBank.createItemData('item_boomerang')
boomerang:setMenuSprite({'icon_boomerang_1', 'icon_boomerang_2'})
boomerang:setItemType(1, require('engine.items.weapons.item_boomerang'))
-- todo uncomment below when item_boomerang takes levels into account
-- boomerang:setItemType(2, require('engine.items.weapons.item_boomerang'))
-- boomerang:setItemType(3, require('engine.items.weapons.item_boomerang'))
boomerang:setEquippable(true)
boomerang:setButtonSlotItem(true)
ItemBank.registerItem(boomerang)