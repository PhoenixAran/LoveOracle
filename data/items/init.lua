-- register items into item bank in this file
local ItemBank = require 'engine.banks.item_bank'


-- sword item
local swordData = ItemBank.createItemData('item_sword')
swordData:setMenuSprite({'icon_sword_1', 'icon_sword_2', 'icon_sword_3'})
ItemBank.registerItem(swordData)

-- shield
local shieldData = ItemBank.createItemData('item_shield')
ItemBank.registerItem(shieldData)

local boomerang = ItemBank.createItemData('item_boomerang')
ItemBank.registerItem(boomerang)
-- TODO register your custom items below