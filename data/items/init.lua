-- register items into item bank in this file
local ItemBank = require 'engine.banks.item_bank'

ItemBank.registerItem(require('engine.items.weapons.item_sword')({}))
ItemBank.registerItem(require('engine.items.weapons.item_shield')({}))
ItemBank.registerItem(require('engine.items.weapons.item_boomerang')({}))
-- TODO register your custom items below