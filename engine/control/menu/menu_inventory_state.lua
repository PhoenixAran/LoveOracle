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

-- TODO we need to support paging inside panels somehow
-- TODO support descriptions having simple {color #hex} tags to change the color until the next tag
-- TODO still need to support ammo and ammo countainers and amount based items
-- TODO event listeners for when items are equipped/unequipped and added/removed from inventory to update the menu

-- TODO support paging
local GRID_SIZE_X = 14
local GRID_SIZE_Y = 4
local GRID_WIDTH = 12
local GRID_HEIGHT = 16

local function indexOf(x, y)
  return (y - 1) * GRID_SIZE_X + x
end

---@class MenuInventoryState : BaseMenuState
---@field itemPanel NinePatchSprite the panel that items are drawn on in the inventory
---@field itemPanelRect NLay.Constraint
---@field itemDetailsPanel NinePatchSprite the panel that item details are drawn on in the inventory
---@field itemDetailsPanelRect NLay.Constraint
---@field currentDescription string the current item description being shown in the details panel
---@field inSubMenu boolean
---@field textPosition integer
---@field textTimer integer
---@field textStart integer
---@field description string
---@field inventoryItemsPopulated boolean
---@field leftTriggerButtonSprite Sprite
---@field rightTriggerButtonSprite Sprite
local MenuInventoryState = Class { __includes = BaseMenuState,
  init = function(self)
    BaseMenuState.init(self)
    -- set up NLay layout
    local uiPadding = 2
    NLay.update(0, 0, GameConfig.window.displayConfig.gameWidth, GameConfig.window.displayConfig.gameHeight)
    local root = NLay

    -- left trigger icons
    local gamepadType = Platform.getGamepadType()
    self.leftTriggerButtonSprite = SpriteBank.getSprite(gamepadType .. '_left_trigger_button')
    self.rightTriggerButtonSprite = SpriteBank.getSprite(gamepadType .. '_right_trigger_button')

    -- top menu box
    -- local panelRectW = -1
    local panelRectW = GameConfig.window.displayConfig.gameWidth * 0.75
    self.itemPanelRect = NLay.constraint(root, root, root, nil, root, uiPadding)
                            :size(panelRectW, GameConfig.window.displayConfig.gameHeight * 0.65)
    -- bottom panel box, used for item description
    self.itemDetailsPanelRect = NLay.constraint(root, self.itemPanelRect, root, nil, root, uiPadding)
                            :size(panelRectW, GameConfig.window.displayConfig.gameHeight * 0.2)

    local ipx, ipy, ipw, iph = self.itemPanelRect:get()
    ipw = math.floor(ipw + 0.5)
    iph = math.floor(iph + 0.5)
    local idpx, idpy, idpw, idph = self.itemDetailsPanelRect:get()
    idpw = math.floor(idpw + 0.5)
    idph = math.floor(idph + 0.5)

    self.itemPanel = SpriteBank.createNinePatchSprite('green_ui_9_patch', ipw, iph, 0, 0)
    self.itemDetailsPanel = SpriteBank.createNinePatchSprite('yellow_ui_9_patch', idpw, idph, 0, 0)

    -- description vars
    self.textPosition = 0
    self.textTimer = 0
    self.textStart = 0

    -- TODO eventually use this
    self.inSubMenu = false

    ---@type SlotGroup
    local group = SlotGroup()
    self.currentSlotGroup = group
    lume.push(self.slotGroups, group)
    ---@type Slot[]
    local slots = { }


    -- create the grid slot
    local rx, ry, rw, rh = self.itemPanelRect:get()
    local xModifier = 8
    local yModifier = 8
    local gridTotalWidth = GRID_WIDTH * GRID_SIZE_X
    
    -- this one centers it
    local gridStartX = rx + (rw - gridTotalWidth) / 2
    --local gridStartX = rx + xModifier

    for y = 1, GRID_SIZE_Y do
      for x = 1, GRID_SIZE_X do
        local index = indexOf(x, y)
        local slotX = gridStartX + GRID_WIDTH * (x - 1)
        local slotY = ry + yModifier + GRID_HEIGHT * (y - 1)
        slots[index] = group:addSlot(slotX, slotY, GRID_WIDTH)
      end
    end
    -- set up slot connections
    for y = 1, GRID_SIZE_Y do
      for x = 1, GRID_SIZE_X do
        local index = (y - 1) * GRID_SIZE_X + x

        local leftX = (x == 1) and GRID_SIZE_X or (x - 1)
        local rightX = (x == GRID_SIZE_X) and 1 or (x + 1)

        local upY = (y == 1) and GRID_SIZE_Y or (y - 1)
        local downY = (y == GRID_SIZE_Y) and 1 or (y + 1)

        slots[index]:setConnection(Direction4.left, slots[indexOf(leftX, y)])
        slots[index]:setConnection(Direction4.right, slots[indexOf(rightX, y)])
        slots[index]:setConnection(Direction4.up, slots[indexOf(x, upY)])
        slots[index]:setConnection(Direction4.down, slots[indexOf(x, downY)])
      end
    end

    self.inventoryItemsPopulated = false
    group.slots = slots
    lume.push(self.slotGroups, group)
  end
}

function MenuInventoryState:getType()
  return 'menu_inventory'
end

function MenuInventoryState:getNextAvailableSlot()
  local slotGroup = self.slotGroups[1]
  if slotGroup == nil then 
    return nil
  end

  for k, v in ipairs(slotGroup:getSlots()) do
    if v:getItem() == nil then
      return v
    end
  end

  return nil
end

function MenuInventoryState:onBegin()
  BaseMenuState.onBegin(self)
  local gameControl = Singletons.gameControl
  if not self.inventoryItemsPopulated and gameControl:getInventory() then
    local inventory = gameControl:getInventory()
    for i, v in ipairs(inventory.items) do
      local item = v
      local slot = self:getNextAvailableSlot()
      if slot then
        slot:setItem(item)
      else
        -- TODO handle no more inventory space in the menu
        break
      end
    end
    self.inventoryItemsPopulated = true
  end
end

function MenuInventoryState:update()
  if Input:pressed('start') then
    self:endState()
  end
end


function MenuInventoryState:draw()
  self:drawRoom()
  local font = AssetManager.getFont('game_font')
  love.graphics.setFont(font)

  love.graphics.setFont(AssetManager.getFont('ui_panel_label'))
  self:drawPanel(self.itemPanelRect, self.itemPanel, 'ITEMS', 12)
  self:drawPanelItems()
  self:drawPanel(self.itemDetailsPanelRect, self.itemDetailsPanel)
  self:debugDrawSlots()
  self:drawTriggerButtonPrompts()
end

function MenuInventoryState:drawPanelItems()
  local slotGroup = self.slotGroups[1]
  if slotGroup then
    for k, v in pairs(slotGroup:getSlots()) do
      local slot = v
      if slot:getItem() then
        local itemSprite = slot:getItem():getMenuSprite()
        local x, y = slot:getPosition()
        itemSprite:draw(x, y)
      end
    end
  end
end

function MenuInventoryState:debugDrawSlots()
  local slotGroup = self.slotGroups[1]
  if slotGroup then
    for k, v in pairs(slotGroup:getSlots()) do
      local slot = v
      local x, y = slot:getPosition()
      love.graphics.rectangle('line', x, y, GRID_WIDTH, GRID_HEIGHT)
    end
  end
end

function MenuInventoryState:resetDescription()
  local slotItem = self.currentSlotGroup:getCurrentSlot():getItem()
  if slotItem then
    self.currentDescription = slotItem:getDescription()
  else
    self.currentDescription = ''
  end

  -- TODO handle description
end

function MenuInventoryState:drawTriggerButtonPrompts()
  -- draw left trigger sprite to the left of the item panel and right trigger sprite to the right of the item panel
  local ipx, ipy, ipw, iph = self.itemPanelRect:get()
  local leftTriggerX = ipx - 16 - 4
  local leftTriggerY = ipy + iph / 2 - self.leftTriggerButtonSprite:getHeight() / 2
  self.leftTriggerButtonSprite:draw(leftTriggerX, leftTriggerY)

  local rightTriggerX = ipx + ipw + 4
  local rightTriggerY = ipy + iph / 2 - self.rightTriggerButtonSprite:getHeight() / 2
  self.rightTriggerButtonSprite:draw(rightTriggerX, rightTriggerY)
end

function MenuInventoryState:updateDescription()
  -- TODO
end

function MenuInventoryState:drawDescription()
  -- TODO
end




return MenuInventoryState