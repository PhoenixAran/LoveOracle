local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local GameState = require 'engine.control.game_state'
local AssetManager = require 'engine.asset_manager'
local SpriteBank = require 'engine.banks.sprite_bank'

--- Game state for inventory screen
--- The default engine implementation if data directory does not implement one
---@class GameStateInventory : GameState
---@field lastRoomState GameState? the last room state that was active. Used to pass into the inventory game state when it is opened from a room state, so that the inventory can be drawn over the gameplay screen
local GameStateInventory = Class { __includes = GameState,
  init = function(self, args)
    -- Initialization code here
    GameState.init(self)
    self.lastRoomState = args.lastRoomState
    
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
  local font = AssetManager.getFont('game_font')
  if self.lastRoomState then
    self.lastRoomState:draw()
  end
  love.graphics.setFont(font)
  love.graphics.printf('Inventory Screen Placeholder', 0, 72 - 6, 256, 'center')
end


return GameStateInventory