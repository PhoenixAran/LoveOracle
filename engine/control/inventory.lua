local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'

local Inventory = Class { __includes = SignalObject,
  init = function(self)
    SignalObject.init(self)
    
    self.items = { }
    self.equippedItems = { }
  end
}

-- connect player signals to inventory
function Inventory:setPlayer(player)
  
end

function Inventory:getType()
  return 'inventory'
end

function Inventory:obtainItem(item)
  
end

return Inventory