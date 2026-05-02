local Class = require 'lib.class'
local lume = require 'lib.lume'
local NLay = require 'lib.nlay'
local SpriteBank = require 'engine.banks.sprite_bank'
local Input = require('engine.singletons').input
local NLay = require 'lib.nlay'
local GameConfig = require 'game_config'
local AssetManager = require 'engine.asset_manager'
local BaseMenuState = require 'engine.control.menu.base_menu_state'
local Singletons = require 'engine.singletons'
local Input = Singletons.input
local Slot = require 'engine.control.menu.slot'
local SlotGroup = require 'engine.control.menu.slot_group'
local Direction4 = require 'engine.enums.direction4'
local Platform = require 'engine.platform'
local GameState = require 'engine.control.game_state'
local GameStateStack = require 'engine.control.game_state_stack'


---@class MenuControl : GameState
---@field menuStateStack GameStateStack
---@field leftTriggerButtonSprite Sprite
---@field rightTriggerButtonSprite Sprite
---@field lastRoomState GameState? the last room state
local MenuControl = Class { __includes = GameState,
  init = function(self, player)
    GameState.init(self)
    self.player = player
    self.menuStateStack = GameStateStack(self)
  end
}

function MenuControl:getType()
  return 'menu_control'
end

function MenuControl:onBegin()
  self.lastRoomState = Singletons.gameControl:getCurrentRoomState()
end

function MenuControl:update()
  local currentMenuState = self.menuStateStack:getCurrentState()
  if currentMenuState then
    currentMenuState:update()
  else
    self:endState()
  end
end

function MenuControl:draw()
  if self.lastRoomState then
    self.lastRoomState:draw()
  end

end

return MenuControl