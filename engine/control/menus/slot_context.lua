local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local ItemBank = require 'engine.utils.item_bank'

local SlotContext = Class { __includes = SignalObject,
  init = function(self, itemData)
    SignalObject.init(self)
  end
}

function SlotContext:getType()
  return 'slot_item'
end

function SlotContext:getName()
end

function SlotContext:draw(x, y)
end

return SlotContext