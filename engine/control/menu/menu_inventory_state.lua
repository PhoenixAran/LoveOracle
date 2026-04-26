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

-- TODO we need to support paging inside panels somehow
-- TODO support descriptions having simple {color #hex} tags to change the color until the next tag
-- TODO still need to support ammo and ammo countainers and amount based items

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
local MenuInventoryState = Class { __includes = BaseMenuState,
  init = function(self)
    BaseMenuState.init(self)
    -- set up NLay layout
    local uiPadding = 2
    NLay.update(0, 0, GameConfig.window.displayConfig.gameWidth, GameConfig.window.displayConfig.gameHeight)
    local root = NLay

    -- top menu box
    self.itemPanelRect = NLay.constraint(root, root, root, nil, root, uiPadding)
                            :size(-1, GameConfig.window.displayConfig.gameHeight * 0.65)
    -- bottom panel box, used for item description
    self.itemDetailsPanelRect = NLay.constraint(root, self.itemPanelRect, root, nil, root, uiPadding)
                            :size(-1, GameConfig.window.displayConfig.gameHeight * 0.2)

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
  end
}

function MenuInventoryState:getType()
  return 'menu_inventory'
end

function MenuInventoryState:onBegin()
  BaseMenuState.onBegin(self)

  -- clear out old slots
  self.slotGroups = { }
  self.currentSlotGroup = nil

  -- build the grid of items
  local GRID_SIZE_X = 10
  local GRID_SIZE_Y = 4

  local slotGroup = SlotGroup()
  self.currentSlotGroup = slotGroup
  for y = 1, GRID_SIZE_Y do
    for x = 1, GRID_SIZE_X do
      local slot = slotGroup:addSlot(nil, 0, 0, 0)
      if x > 1 then
        slot:setConnection('left', slotGroup:getSlotAt((y - 1) * GRID_SIZE_X + (x - 1)))
      end

      if y > 1 then
        slot:setConnection('up', slotGroup:getSlotAt((y - 2) * GRID_SIZE_X + x))
      end
    end
  end


  lume.push(self.slotGroups, slotGroup)
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
  self:drawPanel(self.itemDetailsPanelRect, self.itemDetailsPanel)
  
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

function MenuInventoryState:updateDescription()
  -- TODO
end

function MenuInventoryState:drawDescription()
  -- TODO
end




return MenuInventoryState