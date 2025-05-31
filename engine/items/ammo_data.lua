local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'

---@class AmmoData
---@field sprite Sprite sprite to use in UI
---@field name string
---@field description string
---@field obtainMessage string
---@field cantCollectMessage string
---@field fullMessage string
---@field isAmountBased boolean
---@field amount integer
---@field maxAmount integer
local AmmoData = Class {
  ---@param self AmmoData
  ---@param args table 
  init = function(self, args)
    if args == nil then
      args = { }
    end
    self.sprite = args.sprite
    self.name = args.name
    self.description = args.description
    self.obtainMessage = args.obtainMessage
    self.cantCollectMessage = args.cantCollectMessage
    self.fullMessage = args.fullMessage
    self.isAmountBased = args.isAmountBased
    self.maxAmount = args.maxAmount
  end
}

function AmmoData:getType()
  return 'ammo_data'
end

function AmmoData:getSprite()
  return self.sprite
end

function AmmoData:getName()
  return self.name
end

function AmmoData:getDescription()
  return self.description
end

function AmmoData:getObtainMessage()
  return self.obtainMessage
end

function AmmoData:getCantCollectMessage()
  return self.cantCollectMessage
end

function AmmoData:getFullMessage()
  return self.fullMessage
end

function AmmoData:isAmountBased()
  return self.isAmountBased
end

function AmmoData:getAmount()
  return self.amount
end

function AmmoData:getMaxAmount()
  return self.maxAmount
end

return AmmoData