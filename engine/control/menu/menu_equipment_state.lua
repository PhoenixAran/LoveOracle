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
local InventoryTextReader = require 'engine.control.menu.inventory_text_reader'


-- TODO support paging. Paging might be tough with how slots have a set position. could maybe use scissors 
local GRID_SIZE_X = 14
local GRID_SIZE_Y = 4
local GRID_WIDTH = 12
local GRID_HEIGHT = 16

local function indexOf(x, y)
  return (y - 1) * GRID_SIZE_X + x
end

---@class MenuEquipmentState : BaseMenuState
---@field equipmentPanelParentRect NLay.Constraint
---@field equipmentPanelLeft NinePatchSprite the panel that items in the 'equipment' group are drawn on in the inventory
---@field equipmentPanelLeftRect NLay.Constraint
---@field 
---@field equipmentPanelRightRect NLay.Constraint
---@field detailsPanel NinePatchSprite the panel that item descriptions are drawn on in the inventory
---@field detailsPanelRect NLay.Constraint 
---@field currentDescription string the current item description being shown in the details panel
---@field inSubMenu boolean
---@field inventoryTextReader InventoryTextReader
local MenuEquipmentState = Class { __includes = BaseMenuState,
  ---@param self MenuEquipmentState
  ---@param parent NLay.Constraint the constraint to usefor the root of the menu layout
  init = function(self, parent)
    BaseMenuState.init(self)

    self.inventoryTextReader = InventoryTextReader()
    -- set up NLay layout
    local parentX, parentY, parentW, parentH = parent:get()
    local uiPadding = 1
    NLay.update(0, 0, GameConfig.window.displayConfig.gameWidth, GameConfig.window.displayConfig.gameHeight)
    local usableHeight = parentH - (uiPadding * 2)

    local parentX, parentY, parentW, parentH = parent:get()
    local usableHeight = parentH - (uiPadding * 2)
    self.equipmentPanelParentRect = NLay.constraint(parent, parent, parent, nil, parent, uiPadding)
                            :size(-1, usableHeight * 0.75)
    


    -- bottom panel box, used for item description
    self.detailsPanelRect = NLay.constraint(parent, self.equipmentPanelParentRect, parent, nil, parent, uiPadding)
                            :size(-1, usableHeight * 0.25)

    -- 2/3 menu box left side that will equipement and quest items
    -- 1/3 menu box right side that will house hear containers and currency count

    -- the bottom description box 

  end
}

function MenuEquipmentState:getType()
  return 'menu_equipment_state'
end

function MenuEquipmentState:onBegin()

end

function MenuEquipmentState:update(dt)

end

function MenuEquipmentState:draw()

end

-- TODO implement rest of class

return MenuEquipmentState
