local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local GameState = require 'engine.control.game_state'
local AssetManager = require 'engine.asset_manager'
local SpriteBank = require 'engine.banks.sprite_bank'
local Input = require('engine.singletons').input
local NLay = require 'lib.nlay'
local GameConfig = require 'game_config'
local MenuInventory = require 'engine.menu.menu_inventory'

--- Game state for inventory screen
--- The default engine implementation if data directory does not implement one
---@class GameStateMenu : GameState
---@field menuInventory MenuInventory
---@field lastRoomState GameState?
local GameStateMenu = Class { __includes = GameState,
  init = function(self, args)
    GameState.init(self)
    self.menuInventory = MenuInventory()
    self.lastRoomState = args and args.lastRoomState or nil
  end
}

function GameStateMenu:getType()
  return 'game_state_menu'
end

function GameStateMenu:update()
  if Input:pressed('start') then
    self:endState()
  end
  self.menuInventory:update()
end

function GameStateMenu:draw()
  if self.lastRoomState then
    self.lastRoomState:draw()
  end
  self.menuInventory:draw()
end


return GameStateMenu