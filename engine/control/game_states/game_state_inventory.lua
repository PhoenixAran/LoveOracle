local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local GameState = require 'engine.control.game_state'


--- Game state for inventory screen
--- The default engine implementation if data directory does not implement one
---@class GameStateInventory : GameState
local GameStateInventory = Class {
  init = function(self, args)
    -- Initialization code here
    GameState.init(self)
  end
}

function GameStateInventory:getType()
  return 'game_state_inventory'
end

function GameStateInventory:onBegin()
  
end

function GameStateInventory:update()

end

function GameStateInventory:draw()
  love.graphics.setColor(0, 0, 0, 0.5)
  love.graphics.rectangle('fill', 0, 0, 256, 144)
  love.graphics.setColor(1,1,1)
  love.graphics.printf('Inventory Screen Placeholder', 0, 72 - 6, 256, 'center')
end


return GameStateInventory