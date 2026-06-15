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
local Singletons = require 'engine.singletons'
local InventoryTextReader = require 'engine.control.menu.inventory_text_reader'

-- TODO we need to support paging inside panels somehow
-- TODO support descriptions having simple {color #hex} tags to change the color until the next tag
-- TODO still need to support ammo and ammo countainers and amount based items
-- TODO event listeners for when items are added/removed from inventory to update the menu
-- TODO we have to maintain insert order when saves get reloaded somehow. InventoryItem might just need an insert order field?

-- TODO support paging. Paging might be tough with how slots have a set position. could maybe use scissors 
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
---@field inSubMenu boolean
---@field textPosition integer
---@field textTimer integer
---@field textStart integer
---@field description string
---@field inventoryItemsPopulated boolean
---@field cursorSprite Sprite
---@field inventoryTextReader InventoryTextReader used for item description display
---@field lastHoverSlotItem Slot? the last slot hovererd
local MenuInventoryState = Class { __includes = BaseMenuState,
  ---@param self MenuInventoryState
  ---@param parent NLay.Constraint the constraint to use for the root of the menu layout
  init = function(self, parent)
    BaseMenuState.init(self)
    self:signal('test')

    self.inventoryTextReader = InventoryTextReader()
    self.slotCursor = SpriteBank.getSprite('inventory_cursor_green')

    -- set up NLay layout
    local uiPadding = 1
    NLay.update(0, 0, GameConfig.window.displayConfig.gameWidth, GameConfig.window.displayConfig.gameHeight)


    -- top menu box
    local parentX, parentY, parentW, parentH = parent:get()
    local usableHeight = parentH - (uiPadding * 2)
    self.itemPanelRect = NLay.constraint(parent, parent, parent, nil, parent, uiPadding)
                            :size(-1, usableHeight * 0.75)
    -- bottom panel box, used for item description
    self.itemDetailsPanelRect = NLay.constraint(parent, self.itemPanelRect, parent, nil, parent, uiPadding)
                            :size(-1, usableHeight * 0.25)

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

    -- set current slot to first slot that is enabled and has an item
    for k, v in pairs(group.slots) do
      local slot = v
      if slot:isEnabled() then
        group:setCurrentSlot(slot)
        break
      end
    end
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

--- get the pressed button slot
---@return string? the button slot that was pressed, or nil if no button slot was pressed
function MenuInventoryState:getPressedButtonSlot()
  if Input:pressed('b') then
    return 'b'
  end
  if Input:pressed('x') then
    return 'x'
  end
  if Input:pressed('y') then
    return 'y'
  end
  return nil
end

---@param buttonSlot string
function MenuInventoryState:equipItemFromCursor(buttonSlot)
  local inventory = Singletons.gameControl:getInventory()
  local currentSlot = self.currentSlotGroup:getCurrentSlot()
  if currentSlot and currentSlot:getItem() then
    local item = currentSlot:getItem()
    inventory:equipItem(item, buttonSlot)
  end
end

function MenuInventoryState:onBegin()
  BaseMenuState.onBegin(self)
  local gameControl = Singletons.gameControl
  if not self.inventoryItemsPopulated and gameControl:getInventory() then
    local inventory = gameControl:getInventory()
    local items = inventory:getItemsByGroup('slot_item')
    for i, v in ipairs(items) do
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
  if self.inSubMenu then
    
  else
    self:updateSlotTraversal()
    local buttonSlot = self:getPressedButtonSlot()
    local currentSlot = self.currentSlotGroup:getCurrentSlot()
    if self.lastHoverSlotItem ~= currentSlot then
      self.lastHoverSlotItem = currentSlot
      self:updateDescription()
    end
    -- TODO maybe if item is two handed, prevent equipping to the last button slot, as it needs to take up two
    -- and look nice on the hud
    if buttonSlot and currentSlot:getItem() then
      self:equipItemFromCursor(buttonSlot)
    end
  end
end


function MenuInventoryState:draw()
  self:drawRoom()

  love.graphics.setFont(AssetManager.getFont('ui_panel_label'))
  self:drawPanel(self.itemPanelRect, self.itemPanel, 'ITEMS', 12)
  --self:debugDrawSlots()
  self:drawSlots()
  self:drawPanel(self.itemDetailsPanelRect, self.itemDetailsPanel)

  love.graphics.setFont(AssetManager.getFont('game_font'))
  self:drawDescription()
end


---@deprecated use slot:draw. Might have to go back to this way if we support paging
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

-- description stuff below here, still need to implement
function MenuInventoryState:updateDescription()
  local slotItem = self.currentSlotGroup:getCurrentSlot():getItem()
  if slotItem then
    self.inventoryTextReader:setDescription(slotItem:getDescription())
  end
end

function MenuInventoryState:drawDescription()
  local x,y,w,h = self.itemDetailsPanelRect:get()
  self.inventoryTextReader:draw(x, y, w, h, 6)
end


return MenuInventoryState