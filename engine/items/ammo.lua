local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'

---@class Ammo
---@field ammoData AmmoData
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
  ---@param ammoData AmmoData
  init = function(self, ammoData)
    if ammoData == nil then
      error('AmmoData is required')
    end
    self.ammoData = ammoData
    self.id = lume.uuid()
    self.container = nil
    self.name = ammoData.name
    self.description = ammoData.description
    self.obtainMessage = ammoData.obtainMessage
    self.cantCollectMessage = ammoData.cantCollectMessage
    self.fullMessage = ammoData.fullMessage
    self.isAmountBased = ammoData.isAmountBased
    self.amount = 0
    self.maxAmount = ammoData.maxAmount or 1
    self.isAvailable = true
  end
}

function Ammo:getType()
  return 'ammo'
end

function Ammo:getAmmoData()
  return self.ammoData
end

function Ammo:getId()
  return self.id
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