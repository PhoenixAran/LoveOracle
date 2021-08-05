local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local Direction4 = require 'engine.enums.direction4'

local Slot = Class { __includes = SignalObject, 
  init = function(self)
    SignalObject.init(self, slotContext, x, y, width)
    self:signal('slotSelected')
    -- menu index position
    self.enabled = true
    -- dictionary of other SLot or SlotGroups, indexed by Direction4
    self.slotNeighbors = { }
    self.positionX = x
    self.positionY = y
    self.width = width
    self.slotContext = slotContext
  end
}

function Slot:setPosition(x, y)
  self.positionX = x
  self.positionY = y
end

function Slot:getType()
  return 'slot'
end

function Slot:getSlotContext()
  return self.slotContext
end

function Slot:setSlotContext(slotItem)
  self.slotContext = slotContext
end

function Slot:setEnabled(value)
  self.enabled = value
end

function Slot:isEnabled()
  return self.enabled
end

function Slot:select()
  self:emit('slotSelected', self)
end

function Slot:setContext(context)
  self.slotContext = context
end

function Slot:setNeighbor(direction4, neighbor)
  self.slotNeighbors[direction4] = neighbor
end

function Slot:getNeighbor(direction4)
  return self.slotNeighbors[direction4]
end

function Slot:draw()
  if self.slotContext ~= nil then
    self.slotContext:draw(self.positionX, self.positionY)
  end
end

return Slot