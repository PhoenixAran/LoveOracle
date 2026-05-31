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
local GameConfig = require 'game_config'
local Platform = require 'engine.platform'
local GameState = require 'engine.control.game_state'
local GameStateStack = require 'engine.control.game_state_stack'

local Singletons = require 'engine.singletons'

local MenuInventoryState = require 'engine.control.menu.menu_inventory_state'
local MenuEquipmentState = require 'engine.control.menu.menu_equipment_state'



---@class MenuControl : GameState
---@field menuStateStack GameStateStack
---@field leftShoulderButtonSprite Sprite
---@field rightShoulderButtonSprite Sprite
---@field lastRoomState GameState? the last room state
---@field menuStates table<string, BaseMenuState>
---@field menuConstraint NLay.Constraint the root constraint for menu states
local MenuControl = Class { __includes = GameState,
  init = function(self)
    GameState.init(self)
    self.menuStateStack = GameStateStack(self)
    local root = NLay
    self.menuConstraint = NLay.constraint(root, root, root, nil, root)
                            :size(GameConfig.window.displayConfig.gameWidth * 0.75, 
                                  GameConfig.window.displayConfig.gameHeight * 0.88)
    local menuInventoryState = MenuInventoryState(self.menuConstraint)
    local menuEquipmentState = MenuEquipmentState(self.menuConstraint)
    self.menuStates = {
      ['inventory'] = menuInventoryState,
      ['equipment'] = menuEquipmentState
    }

    -- trigger icons
    local gamepadType = Platform.getGamepadType()
    self.leftShoulderButtonSprite = SpriteBank.getSprite(gamepadType .. '_left_trigger_button')
    self.rightShoulderButtonSprite = SpriteBank.getSprite(gamepadType .. '_right_trigger_button')
  end
}

function MenuControl:getType()
  return 'menu_control'
end

--- push a menu state onto the state stack
--- @param menuState BaseMenuState|string the menu state to push
function MenuControl:pushState(menuState)
  if type(menuState) == 'string' then
    menuState = self.menuStates[menuState]
  end
  self.menuStateStack:pushState(menuState)
end


function MenuControl:popState()
  self.menuStateStack:popState()
end


function MenuControl:onBegin()
  self.lastRoomState = Singletons.gameControl:getCurrentRoomState()
end

function MenuControl:update()
  local currentMenuState = self.menuStateStack:getCurrentState()
  if currentMenuState and not Input:pressed('start') then
    currentMenuState:update()
  else
    self:endState()
  end
end

function MenuControl:debugDrawMenuConstraint()
  local x, y, w, h = self.menuConstraint:get()
  love.graphics.setColor(1, 0, 0)
  love.graphics.rectangle('line', x, y, w, h)
  love.graphics.setColor(1, 1, 1)
end

--- draw trigger button prompts on the sides to let users know
--- they can press them to switch between the different types of menus
function MenuControl:drawTriggerButtonPrompts()
    -- draw left trigger sprite to the left of the item panel and right trigger sprite to the right of the item panel
  local x, y, w, h = self.menuConstraint:get()
  local leftTriggerX = x - 16 - 4
  -- if Platform.getGamepadType() == 'pc' then
  --   leftTriggerX = leftTriggerX - 8
  -- end
  local leftTriggerY = y + h / 2 - self.leftShoulderButtonSprite:getHeight() / 2
  self.leftShoulderButtonSprite:draw(leftTriggerX, leftTriggerY)

  local rightTriggerX = x + w + 4
  local rightTriggerY = y + h / 2 - self.rightShoulderButtonSprite:getHeight() / 2
  self.rightShoulderButtonSprite:draw(rightTriggerX, rightTriggerY)
end

function MenuControl:draw()
  if self.lastRoomState then
    self.lastRoomState:draw()
  end
  local currentMenuState = self.menuStateStack:getCurrentState()
  if currentMenuState then
    currentMenuState:draw()
  end
  self:drawTriggerButtonPrompts()
end

return MenuControl