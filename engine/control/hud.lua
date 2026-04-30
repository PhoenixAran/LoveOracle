local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local SignalObject = require 'engine.signal_object'
local AssetManager = require 'engine.asset_manager'
local SpriteBank = require 'engine.banks.sprite_bank'
local NLay = require 'lib.nlay'
local GameConfig = require 'game_config'
local DisplayHandler = require 'engine.display_handler'
local Singletons = require 'engine.singletons'
local GamepadGuesser = require 'lib.gamepadguesser'
local Platform = require 'engine.platform'



---@class Hud : SignalObject
---@field NinePatch NinePatchSprite
---@field player Player
---@field statusBarBorder NinePatchSprite stat bar border nine patch sprite
---@field hudRect NLay.Constraint the whole bottom HUD area
---@field hudLeftRect NLay.Constraint the left section of the bottom HUD area, used for player health and madness bars
---@field hudCenterRect NLay.Constraint the center section of the bottom HUD area, used for player stamina bar
---@field hudRightRect NLay.Constraint the right section of the bottom HUD area, used for other info such as score or currency
---@field equipmentSlot Sprite the sprite used to indicate an equipment slot, drawn in the right section of the HUD
---@field bSlotButtonSprite Sprite the sprite used to indicate the B button equipment slot
---@field xSlotButtonSprite Sprite the sprite used to indicate the X button equipment slot
---@field ySlotButtonSprite Sprite the sprite used to indicate the Y button equipment slot
---@field slots string[] list of the three equipment slot keys in order of equipment slot, e.g. {'b', 'x', 'y'}
---@field slotButtonSprites Sprite[] list of the three button sprites in order of equipment slot
---@field heartSprites Sprite[] list of the heart sprites in order of fullness, from empty to full
---@field dynamicHealth integer used to slowly increment player health
---@field healthTimer integer used to update the health positively at a slower pace
local Hud = Class { __includes = SignalObject,
  init = function(self, args)
    SignalObject.init(self)

    self.statusBarBorder = SpriteBank.createNinePatchSprite('hud_bar_border', 16, nil, 0, 0)

    -- Set up NLay layout area
    local uiPadding = 1
    NLay.update(0, 0, GameConfig.window.displayConfig.gameWidth, GameConfig.window.displayConfig.gameHeight)
    local root = NLay

    -- whole bottom HUD strip
    self.hudRect = NLay.constraint(root, nil, root, root, root)
      :size(0, 16)

    -- split bottom strip into 3 equal horizontal sections
    local leftRect, centerRect, rightRect = NLay.split(self.hudRect, 'horizontal', 39, 33, 30)
 
    self.hudLeftRect = leftRect:margin(uiPadding)
    self.hudCenterRect = centerRect:margin(uiPadding)
    self.hudRightRect = rightRect:margin(uiPadding)

    self.equipmentSlot = SpriteBank.getSprite('hud_equipment_slot')
    
    
    local gamepadType = Platform.getGamepadType()

    self.bSlotButtonSprite = SpriteBank.getSprite(gamepadType .. '_b_slot_button')
    self.xSlotButtonSprite = SpriteBank.getSprite(gamepadType .. '_x_slot_button')
    self.ySlotButtonSprite = SpriteBank.getSprite(gamepadType .. '_y_slot_button')

    self.slotButtonSprites = { self.bSlotButtonSprite, self.xSlotButtonSprite, self.ySlotButtonSprite }
    self.slots = { 'b', 'x', 'y' }
    self.heartSprites = {
      SpriteBank.getSprite('heart_empty'),
      SpriteBank.getSprite('heart_quarter'),
      SpriteBank.getSprite('heart_half'),
      SpriteBank.getSprite('heart_three_quarters'),
      SpriteBank.getSprite('heart_full'),
    }
    self.dynamicHealth = 0
    self.healthTimer = 0
  end
}

function Hud:getType()
  return 'hud'
end


---@param player Player
function Hud:setPlayer(player)
  self.player = player
  local health = self.player.health
  health:connect('damage_taken', self, 'onDamageTaken')
  health:connect('max_health_changed', self, 'onMaxHealthChanged')
  health:connect('health_increased', self, 'onHealthIncreased')
  
  self.dynamicHealth = self.player:getHealth()
  self.healthTimer = 0

  self:updateHealthBarWidth()
end


function Hud:updateHealthBarWidth()
  local BASE_HEALTHBAR_WIDTH = 24
  local MAX_HEALTHBAR_WIDTH = 60
  local BASE_MAX_HEALTH = 3
  local HEALTHBAR_GROWTH = 0.12

  local maxHealth = self.player.health:getMaxHealth()
  local healthDelta = math.max(0, maxHealth - BASE_MAX_HEALTH)

  local width = BASE_HEALTHBAR_WIDTH
    + (MAX_HEALTHBAR_WIDTH - BASE_HEALTHBAR_WIDTH)
    * (1 - math.exp(-HEALTHBAR_GROWTH * healthDelta))

  self.statusBarBorder:setWidth(math.floor(width + 0.5))
end

function Hud:update()
  local health = self.player:getHealth()
  if self.dynamicHealth < health then
    if self.healthTimer < 3 then
      self.healthTimer = self.healthTimer + 1
    else
      self.dynamicHealth = self.dynamicHealth + 1
      self.healthTimer = 0
      if self.dynamicHealth % 4 == 0 then
        -- TODO play get heart sound
      end
    end
  elseif self.dynamicHealth > health then
    self.dynamicHealth = self.dynamicHealth - 1
  else
    self.healthTimer = 0
  end
end

function Hud:draw()
  -- HUD background
  love.graphics.setColor(184 / 255, 155 / 255, 114 / 255)
  love.graphics.rectangle('fill', 0, 144 - 16, 256, 16)
  love.graphics.setColor(1,1,1)

  --self:debugDrawNlaySections()
  --self:drawStatBars()
  self:drawHearts()
  self:drawEquippedItems()
end

function Hud:debugDrawNlaySections()
    -- debug: draw rect outlines of HUD sections
  love.graphics.setColor(1, 1, 1, 0.3)
  local x, y, w, h
  x, y, w, h = self.hudLeftRect:get()
  love.graphics.rectangle('line', x, y, w, h)

  x, y, w, h = self.hudCenterRect:get()
  love.graphics.rectangle('line', x, y, w, h)

  x, y, w, h = self.hudRightRect:get()
  love.graphics.rectangle('line', x, y, w, h)

  -- reset color
  love.graphics.setColor(1, 1, 1, 1)
end

-- middle section of our hud
-- TODO use this when we add a stamina bar and/or sanity bar
-- did the health stuff just for testing
function Hud:drawStatBars()
  -- TODO draw madness bars and stamina bars eventually

  local x, y, w, h = self.hudCenterRect:get()
  x, y = math.floor(x + 0.5), math.floor(y + 0.5)

  local FILL_BAR_ADJUST_X = 1
  local FILL_BAR_ADJUST_Y = 1
  local FILL_BAR_ADJUST_W = -2
  local FILL_BAR_ADJUST_H = -2
  -- black background for health border
  local statusW, statusH = self.statusBarBorder:getWidth(), self.statusBarBorder:getHeight()
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle('fill', x + FILL_BAR_ADJUST_X, y + FILL_BAR_ADJUST_Y, statusW + FILL_BAR_ADJUST_W,statusH + FILL_BAR_ADJUST_H)
  love.graphics.setColor(1, 1, 1, 1)

  local maxHealth = self.player.health:getMaxHealth()
  local currentHealth = self.player.health:getHealth()
  local healthRatio = maxHealth > 0 and (currentHealth / maxHealth) or 0

  -- compute scale so healthBarFill stretches to match the nine-patch width
  local fillWidth = math.floor((self.statusBarBorder:getWidth() - 2) * healthRatio + 0.5)
  local fillHeight = self.statusBarBorder:getHeight() + FILL_BAR_ADJUST_H
  if fillWidth > 0 then
    love.graphics.setColor(254 / 255, 30 / 255, 42 / 255, 1)
    love.graphics.rectangle('fill', x + FILL_BAR_ADJUST_X, y + FILL_BAR_ADJUST_Y, fillWidth, fillHeight)
    love.graphics.setColor(1, 1, 1, 1)
  end
  self.statusBarBorder:draw(x, y)
end

function Hud:drawHearts()
  local HEART_SIZE = 8
  local x, y, w, h = self.hudCenterRect:get()
  x, y = math.floor(x + 0.5), math.floor(y + 0.5)
  local maxHearts = math.floor(self.player:getMaxHealth() / 4)
  for i = 0, maxHearts - 1 do
    local fullness = math.max(0, math.min(self.dynamicHealth - i * 4, 4))
    local drawX = x + (i % 7) * HEART_SIZE
    local drawY = y + math.floor(i / 7) * HEART_SIZE
    self.heartSprites[fullness + 1]:draw(drawX, drawY)
  end
end

function Hud:drawEquippedItems()
  -- draw the three equipment slots
  local x, y, w, h = self.hudLeftRect:get()
  x, y = math.floor(x + 0.5), math.floor(y + 0.5)
  local startX = x
  local spaceBetweenButtonAndSlot = 7
  local menuSpriteOffsetX = 12
  local menuSpriteOffsetY = -1
  local equipmentBorderSpace = 30
  for i = 1, #self.slotButtonSprites do
    local drawX, drawY = startX + ( (i - 1) * equipmentBorderSpace), y
    local slotButtonSprite = self.slotButtonSprites[i]
    slotButtonSprite:draw(drawX, drawY)
    self.equipmentSlot:draw(drawX + spaceBetweenButtonAndSlot, drawY)
    -- TODO get from Inventory singleton instead of player directly
    local slotItems = self.player.buttonSlotItems
    local slotButton = self.slots[i]
    local item = slotItems[slotButton]
    if item then
      local menuSprite = item:getMenuSprite()
      if menuSprite then
        menuSprite:draw(drawX + menuSpriteOffsetX, drawY + menuSpriteOffsetY)
      end
    end
  end
end

function Hud:drawEquipmentSlot(slotButton, x, y)
  -- TODO
end


-- callbacks
function Hud:onDamageTaken(newHealth, oldHealth)
  -- TODO
end

function Hud:onMaxHealthChanged(newMaxHealth, oldMaxHealth)
  self:updateHealthBarWidth()
end

function Hud:onHealthIncreased(newHealth, oldHealth)
  -- TODO
end


return Hud