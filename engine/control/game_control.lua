local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local Inventory = require 'engine.contro.inventory'
local lume = require 'lib.lume'
local vector = require 'lib.vector'

local GameControl = Class { __includes = SignalObject,
  init = function(self)
    self.inventory = Inventory()  
    self.player = nil
  end
}

function GameControl:getInventory()
  return self.inventory
end

function GameControl:getPlayer()
  return self.player
end

return GameControl