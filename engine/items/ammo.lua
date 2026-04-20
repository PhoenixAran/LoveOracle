local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'

---@deprecated use Item class instead for now. Leaving this here when I change my mind
---@class Ammo
---@field id string
---@field container Item
---@field name string
---@field description string
---@field obtainMessage string
---@field cantCollectMessage string
---@field fullMessage string
---@field isAmountBased boolean
---@field amount integer
---@field maxAmount integer
---@field isAvailable boolean
local Ammo = Class {
  ---@param self Ammo
  init = function(self, args)
    self.container = nil
    self.name = args.name
    self.description = args.description
    self.obtainMessage = args.obtainMessage
    self.cantCollectMessage = args.cantCollectMessage
    self.fullMessage = args.fullMessage
    self.isAmountBased = args.isAmountBased
    self.amount = 0
    self.maxAmount = args.maxAmount or 1
    self.isAvailable = true
  end
}

function Ammo:getType()
  return 'ammo'
end

function Ammo:getContainer()
  return self.container
end

function Ammo:getName()
  return self.name
end

function Ammo:getDescription()
  return self.description
end

function Ammo:getObtainMessage()
  return self.obtainMessage
end

function Ammo:getCantCollectMessage()
  return self.cantCollectMessage
end

function Ammo:getFullMessage()
  return self.fullMessage
end

function Ammo:isAmountBased()
  return self.isAmountBased
end

function Ammo:getAmount()
  return self.amount
end

function Ammo:getMaxAmount()
  return self.maxAmount
end

function Ammo:isAvailable()
  return self.isAvailable
end

function Ammo:isEmpty()
  return not self.isAmountBased or self.amount <= 0
end

function Ammo:isFull()
  return not self.isAmountBased or self.amount >= self.maxAmount
end

---@param x integer
---@param y integer
function Ammo:drawSlot(x, y)
  -- TODO
end

return Ammo