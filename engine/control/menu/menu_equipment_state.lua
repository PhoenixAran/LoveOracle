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
local LEFT_GRID_HEIGHT = 16
local LEFT_GRID_WIDTH = 12
local LEFT_GRID_SIZE_Y = 4
local LEFT_GRID_SIZE_X = 9


---@class MenuEquipmentState : BaseMenuState
---@field equipmentPanelParentRect NLay.Constraint
---@field equipmentPanelLeft NinePatchSprite the panel that items in the 'equipment' group are drawn on in the inventory
---@field equipmentPanelLeftRect NLay.Constraint
---@field equipmentPanelRight NinePatchSprite
---@field equipmentPanelRightRect NLay.Constraint
---@field detailsPanel NinePatchSprite the panel that item descriptions are drawn on in the inventory
---@field detailsPanelRect NLay.Constraint 
---@field currentDescription string the current item description being shown in the details panel
---@field inSubMenu boolean
---@field inventoryTextReader InventoryTextReader
---@field itemsPopulated boolean
---@field lastHoverSlotItem Slot? the last slot hovererd
local MenuEquipmentState = Class { __includes = BaseMenuState,
  ---@param self MenuEquipmentState
  ---@param parent NLay.Constraint the constraint to usefor the root of the menu layout
  init = function(self, parent)
    BaseMenuState.init(self)

    self.inventoryTextReader = InventoryTextReader()
    self.slotCursor = SpriteBank.getSprite('inventory_cursor_green')

    self.inventoryTextReader = InventoryTextReader()
    -- set up NLay layout and panel rects
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

    -- 1/3 menu box right side that will house equipment and quest items
    self.equipmentPanelRightRect = NLay.constraint(self.equipmentPanelParentRect, self.equipmentPanelParentRect, nil, self.equipmentPanelParentRect, self.equipmentPanelParentRect, {0, uiPadding, 0, uiPadding})
                            :size((parentW) * (1/3), -1)

    -- 1/3 menu box left side that will house heart containers and currency count
    self.equipmentPanelLeftRect = NLay.constraint(self.equipmentPanelParentRect, self.equipmentPanelParentRect, self.equipmentPanelParentRect, self.equipmentPanelParentRect, self.equipmentPanelRightRect, { 0, uiPadding, 0, uiPadding})
                            :size((parentW) * (2/3), -1)
    -- panel sprites

    -- equipement panel left dimensions
    local eplx, eply, eplw, eplh = self.equipmentPanelLeftRect:get()
    eplw = math.floor(eplw + 0.5)
    eplh = math.floor(eplh + 0.5)
    self.equipmentPanelLeft = SpriteBank.createNinePatchSprite('green_ui_9_patch', eplw, eplh, 0, 0)
    
    -- equipment panel right dimensions
    local eprx, epry, eprw, eprh = self.equipmentPanelRightRect:get()
    eprw = math.floor(eprw + 0.5)
    eprh = math.floor(eprh)
    self.equipmentPanelRight = SpriteBank.createNinePatchSprite('red_ui_9_patch', eprw, eprh, 0, 0)

    local idpx, idpy, idpw, idph = self.detailsPanelRect:get()
    idpw = math.floor(idpw + 0.5)
    idph = math.floor(idph + 0.5)
    self.detailsPanel = SpriteBank.createNinePatchSprite('yellow_ui_9_patch', idpw, idph, 0, 0)

    -- set up right grid slot


    -- create the left grid slot in the equipment slot
    ---@type SlotGroup
    local group = SlotGroup()
    self.currentSlotGroup = group
    lume.push(self.slotGroups, group)
    ---@type Slot[]
    local slots = { }

    local function indexOf(x, y)
      return (y - 1) * LEFT_GRID_SIZE_X + x
    end
    local rx, ry, rw, rh = self.equipmentPanelLeftRect:get() 
    local xModifier = 8
    local yModifier = 8
    local gridTotalWidth = LEFT_GRID_WIDTH * LEFT_GRID_SIZE_X

    local gridStartX = rx + (rw - gridTotalWidth) / 2

    for y = 1, LEFT_GRID_SIZE_Y do
      for x = 1, LEFT_GRID_SIZE_X do
        local index = indexOf(x, y)
        local slotX = gridStartX + LEFT_GRID_WIDTH * (x - 1)
        local slotY = ry + yModifier + LEFT_GRID_HEIGHT * (y - 1)
        slots[index] = group:addSlot(slotX, slotY, LEFT_GRID_WIDTH)
      end
    end

    -- set up slot connections
    for y = 1, LEFT_GRID_SIZE_Y do
      for x = 1, LEFT_GRID_SIZE_X do
        local index = (y - 1) * LEFT_GRID_SIZE_X + x

        local leftX = (x == 1) and LEFT_GRID_SIZE_X or (x - 1)
        local rightX = (x == LEFT_GRID_SIZE_X) and 1 or (x + 1)

        local upY = (y == 1) and LEFT_GRID_SIZE_Y or (y - 1)
        local downY = (y == LEFT_GRID_SIZE_Y) and 1 or (y + 1)

        slots[index]:setConnection(Direction4.left, slots[indexOf(leftX, y)])
        slots[index]:setConnection(Direction4.right, slots[indexOf(rightX, y)])
        slots[index]:setConnection(Direction4.up, slots[indexOf(x, upY)])
        slots[index]:setConnection(Direction4.down, slots[indexOf(x, downY)])
      end
    end

    self.itemsPopulated = false
    group.slots = slots
    lume.push(self.slotGroups, group)

    -- set current slot to first slot that is enabled
  end
}

function MenuEquipmentState:getType()
  return 'menu_equipment_state'
end

function MenuEquipmentState:onBegin()
  BaseMenuState.onBegin(self)
end

function MenuEquipmentState:update(dt)
  if self.inSubMenu then

  else
    self:updateSlotTraversal()
    local currentSlot = self.currentSlotGroup:getCurrentSlot()
    if self.lastHoverSlotItem ~= currentSlot then
      self.lastHoverSlotItem = currentSlot
      self:updateDescription()
    end

  end
end

function MenuEquipmentState:updateDescription()
  local slotItem = self.currentSlotGroup:getCurrentSlot():getItem()
  if slotItem then
    self.inventoryTextReader:setDescription(slotItem:getDescription())
  end
end

function MenuEquipmentState:debugDrawSlots()
  for _, slotGroup in ipairs(self.slotGroups) do
    for k, v in pairs(slotGroup:getSlots()) do
      local slot = v
      local x, y = slot:getPosition()
      love.graphics.rectangle('line', x, y, LEFT_GRID_WIDTH, LEFT_GRID_HEIGHT)
    end
  end
end

function MenuEquipmentState:draw()
  self:drawRoom()
  love.graphics.setFont(AssetManager.getFont('ui_panel_label'))
  self:drawPanel(self.equipmentPanelLeftRect, self.equipmentPanelLeft, 'EQUIPMENT', 12)
  self:drawPanel(self.equipmentPanelRightRect, self.equipmentPanelRight)
  self:drawPanel(self.detailsPanelRect, self.detailsPanel)
  self:debugDrawSlots()
end

-- TODO implement rest of class

return MenuEquipmentState
