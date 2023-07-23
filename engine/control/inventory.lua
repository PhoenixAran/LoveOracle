local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local ItemBank = require 'engine.banks.item_bank'

local SLOT_B = 1 -- should be hardcoded to always be equipped to sword if it exists
local SLOT_X = 2
local SLOT_Y = 3

---@class Inventory
---@field items table
local Inventory = Class { __includes = SignalObject,
  init = function(self, gameControl)
    SignalObject.init(self)
    
    self.items = { }
    self.equippedItems = { }

    self.gameControl = gameControl or nil
    self.piecesOfHeart = nil
    self.player = nil
  end
}

-- connect player signals to inventory
function Inventory:setPlayer(player)
  self.player = player
end

function Inventory:getType()
  return 'inventory'
end

function Inventory:addItem(itemId)
  self.items[itemId] = ItemBank.getItem(itemId)
end

function Inventory:removeItem(itemId)
  self.items[itemId] = nil
end

function Inventory:equipItem(itemId, slot)
  
end

function Inventory:unequipItem(itemId, slot)

end

return Inventory