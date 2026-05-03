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

---@class MenuEquipmentState : BaseMenuState
local MenuEquipmentState = Class { __includes = BaseMenuState,
  init = function(self)
    BaseMenuState.init(self)
  end
}

function MenuEquipmentState:getType()
  return 'menu_equipment_state'
end

-- TODO implement rest of class

return MenuEquipmentState
