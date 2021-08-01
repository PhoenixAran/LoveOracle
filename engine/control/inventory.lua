local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'

local Inventory = Class { __includes = SignalObject,
  init = function(self, gameControl)
    SignalObject.init(self)
    
    self.items = { }
    self.equippedItems = { }

    self.gameControl = gameControl or nil
    self.piecesOfHeart = nil
    self.player = player
  end
}

-- connect player signals to inventory
function Inventory:setPlayer(player)
  self.player = player
end

function Inventory:getType()
  return 'inventory'
end

function Inventory:obtainItem(itemId)
  
end

return Inventory