local Class = require 'lib.class'
local lume = require 'lib.lume'
local GameState = require 'engine.control.game_state'
local Input = require('engine.singletons').input
local SlotGroup = require 'engine.control.menu.slot_group'
local Direction4 = require 'engine.enums.direction4'
local AngleSnap = require 'engine.enums.angle_snap'
local SpriteBank = require 'engine.banks.sprite_bank'
local Singletons = require 'engine.singletons'
local AssetManager = require 'engine.asset_manager'

--- base class you can use for menu states
--- contains convenience methods for navigating between slots and slot groups
---@class BaseMenuState : GameState
---@field slotGroups SlotGroup[]
---@field currentSlotGroup SlotGroup
---@field slotCursor Sprite|CompositeSprite the cursor that is drawn over the currently selected slot
---@field drawLastRoomState boolean whether to draw the last room state in the background when this menu is open. Defaults to true, but can be set to false for menus like the start menu where you don't want to show the game screen in the background
---@field lastRoomState GameState? the last room state
local BaseMenuState = Class { __includes = GameState,
  init = function(self)
    GameState.init(self)
    self.slotGroups = {}
    self.currentSlotGroup = nil
    self.slotCursor = SpriteBank.getSprite('inventory_cursor_hover')
    self.drawLastRoomState = true
  end
}

function BaseMenuState:getType()
  return 'menu_state'
end

function BaseMenuState:onBegin()
  self.lastRoomState = Singletons.gameControl:getCurrentRoomState()
end

function BaseMenuState:getCurrentSlotGroup()
  return self.currentSlotGroup
end

function BaseMenuState:getDirection4FromControl()
  local x, y = Input:get('move')
  x, y = AngleSnap.toVector(AngleSnap.to4, x, y)
  return Direction4.getDirection(x, y)
end

function BaseMenuState:updateSlotTraversal()
  if self.currentSlotGroup then
    self:nextSlot(self:getDirection4FromControl())
  end
end

---@param direction4 Direction4
function BaseMenuState:nextSlot(direction4)
  if self.currentSlotGroup == nil then
    return
  end

  local currentSlot = self.currentSlotGroup:getCurrentSlot()
  if currentSlot == nil then 
    return
  end

  local connection = currentSlot:getConnectionAt(direction4)
  if connection == nil then
    return
  end

  if connection:getType() == 'slot' then
    ---@type Slot
    local slot = connection
    slot:select()
    if not slot:isEnabled() then
      self:nextSlot(direction4)
    end
    -- TODO play audio sound
  else
    -- slot_group
    ---@type SlotGroup
    self.currentSlotGroup = connection
    -- TODO play an audio sound
  end
end

---@param slot Slot
function BaseMenuState:drawSlotCursor(slot)
  local x, y = slot.positionX, slot.positionY
  self.slotCursor:draw(x, y)
end

function BaseMenuState:drawSlots()
  if self.currentSlotGroup then
    self:drawSlotCursor(self.currentSlotGroup:getCurrentSlot())
  end

  for _, slotGroup in ipairs(self.slotGroups) do
    slotGroup:draw()
  end
end

--- draws a 9 patch sprite with optional label given a rect constraint to determine where to draw the panel
--- the font used will be the last one set via love graphics.setFont, so make sure to set the font before calling this method
---@param rectConstraint NLay.Constraint
---@param panelSprite NinePatchSprite
---@param panelLabel string|nil optional label to draw in the top left of the panel
---@param xPadding number|nil optional extra padding to add to the left and right of the panel when drawing the label. Defaults to 4.
function BaseMenuState:drawPanel(rectConstraint, panelSprite, panelLabel, xPadding)
  local originalWidth = panelSprite:getWidth()
  local originalHeight = panelSprite:getHeight()
  if xPadding == nil then
    xPadding = 4
  end
  local itemPanelX, itemPanelY, itemPanelW, itemPanelH = rectConstraint:get()
  panelSprite:setWidth(itemPanelW)
  panelSprite:setHeight(itemPanelH)
  panelSprite:draw(itemPanelX, itemPanelY, 1)
  panelSprite:setWidth(originalWidth)
  panelSprite:setHeight(originalHeight)

  if panelLabel then
    local font = love.graphics.getFont()

    -- draw background for text
    local textW = font:getWidth(panelLabel)
    local textH = font:getHeight()

    local rectW = textW + 4
    local rectH = textH

    local rectX = itemPanelX + 12 - 2
    local rectY = itemPanelY

    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", rectX, rectY, rectW, rectH)

    -- center text inside the rectangle
    local textX = rectX + (rectW - textW) / 2
    local textY = rectY + (rectH - textH) / 2

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(panelLabel, textX, textY)
  end
end

--- draws last room state if drawLastRoomState is true and lastRoomState is not nil
function BaseMenuState:drawRoom()
  if self.lastRoomState and self.drawLastRoomState then
    self.lastRoomState:draw()
  end
end

return BaseMenuState

