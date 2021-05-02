local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local Entities = require 'engine.entities.entities'
local Inventory = require 'engine.control.inventory'
local lume = require 'lib.lume'
local vector = require 'lib.vector'

local GameControl = Class { __includes = SignalObject,
  init = function(self)
    self.inventory = Inventory()  
    self.player = nil
    self.camera = nil

    self.entities = Entities()
    
    self.map = nil
    self.currentRoom = nil

  end
}

function GameControl:getType()
  return 'game_control'
end

function GameControl:getInventory()
  return self.inventory
end

function GameControl:getPlayer()
  return self.player
end

function GameControl:setPlayer(player)
  self.player = player
end

function GameControl:getCamera()
  return self.camera
end

function GameControl:setCamera(camera)
  self.camera = camera
end

function GameControl:update(dt)
  self.entitites:update()
end

function GameControl:draw()
  self.entities:draw()
end

return GameControl