local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local SignalObject = require 'engine.signal_object'
local AssetManager = require 'engine.asset_manager'
local SpriteBank = require 'engine.banks.sprite_bank'
local NLay = require 'lib.nlay'
local GameConfig = require 'game_config'
local DisplayHandler = require 'engine.display_handler'




---@class Hud : SignalObject
---@field NinePatch NinePatchSprite
---@field player Player
---@field statusBarBorder NinePatchSprite stat bar border nine patch sprite
---@field hudRect NLay.Constraint the whole bottom HUD area
---@field hudLeftRect NLay.Constraint the left section of the bottom HUD area, used for player health and madness bars
---@field hudCenterRect NLay.Constraint the center section of the bottom HUD area, used for player stamina bar
---@field hudRightRect NLay.Constraint the right section of the bottom HUD area, used for other info such as score or currency
local Hud = Class { __includes = SignalObject,
  init = function(self, args)
    SignalObject.init(self)

    self.statusBarBorder = SpriteBank.createNinePatchSprite('ui_bar_border', 16)

    -- Set up NLay layout area
    local uiPadding = 1
    NLay.update(0, 0, GameConfig.window.displayConfig.gameWidth, GameConfig.window.displayConfig.gameHeight)
    local root = NLay

    -- whole bottom HUD strip
    self.hudRect = NLay.constraint(root, nil, root, root, root)
      :size(0, 16)

    -- split bottom strip into 3 equal horizontal sections
    local leftRect, centerRect, rightRect = NLay.split(self.hudRect, "horizontal", 1, 1, 1)
 
    self.hudLeftRect = leftRect:margin(uiPadding)
    self.hudCenterRect = centerRect:margin(uiPadding)
    self.hudRightRect = rightRect:margin(uiPadding)
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
  self:updateHealthBarWidth()
end

local BASE_HEALTHBAR_WIDTH = 24
local MAX_HEALTHBAR_WIDTH = 60
local BASE_MAX_HEALTH = 3
local HEALTHBAR_GROWTH = 0.12
function Hud:updateHealthBarWidth()
  local maxHealth = self.player.health:getMaxHealth()
  local healthDelta = math.max(0, maxHealth - BASE_MAX_HEALTH)

  local width = BASE_HEALTHBAR_WIDTH
    + (MAX_HEALTHBAR_WIDTH - BASE_HEALTHBAR_WIDTH)
    * (1 - math.exp(-HEALTHBAR_GROWTH * healthDelta))

  self.statusBarBorder:setWidth(math.floor(width + 0.5))
end

function Hud:update()

end

function Hud:draw()
  -- HUD background
  love.graphics.setColor(184 / 255, 155 / 255, 114 / 255)
  love.graphics.rectangle('fill', 0, 144 - 16, 256, 16)
  love.graphics.setColor(1,1,1)

  self:debugDrawNlaySections()
  self:drawHealthBar()
end

function Hud:debugDrawNlaySections()
    -- debug: draw rect outlines of HUD sections
  love.graphics.setColor(1, 1, 1, 0.5)
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

function Hud:drawHealthBar()
  -- draw our border
  local x, y, w, h = self.hudLeftRect:get()

  -- base top-left corner where all bar sprites should start
  local borderOx, borderOy = self.statusBarBorder:getOrigin()
  local barX, barY = x + borderOx, y + borderOy
  
  -- black background for health border
  local STATUS_BAR_FILL_WIDTH_ADJUST = 2
  local STATUS_BAR_FILL_HEIGHT_ADJUST = 1.5
  love.graphics.setColor(0, 0, 0, 1)
  love.graphics.rectangle(
    'fill',
    barX - borderOx + 1,
    barY - borderOy + 1,
    self.statusBarBorder:getWidth() - STATUS_BAR_FILL_WIDTH_ADJUST,
    self.statusBarBorder:getHeight() - STATUS_BAR_FILL_HEIGHT_ADJUST
  )
  love.graphics.setColor(1, 1, 1, 1)

  local maxHealth = self.player.health:getMaxHealth()
  local currentHealth = self.player.health:getHealth()
  local healthRatio = maxHealth > 0 and (currentHealth / maxHealth) or 0
  
  -- compute scale so healthBarFill stretches to match the nine-patch width
  local fillWidth = math.floor((self.statusBarBorder:getWidth() - 2) * healthRatio + 0.5)
  if fillWidth > 0 then
    love.graphics.setColor(254 / 255, 30 / 255, 42 / 255, 1)
    love.graphics.rectangle(
      'fill',
      barX - borderOx + 1,
      barY - borderOy + 1,
      fillWidth,
      self.statusBarBorder:getHeight() - STATUS_BAR_FILL_HEIGHT_ADJUST
    )
    love.graphics.setColor(1, 1, 1, 1)
  end
  self.statusBarBorder:draw(barX, barY)
end



-- callbacks
function Hud:onDamageTaken(damageAmount, oldHealth)
  -- TODO
end

function Hud:onMaxHealthChanged(newMaxHealth, oldMaxHealth)
  self:updateHealthBarWidth()
end

function Hud:onHealthIncreased(newHealth, oldHealth)
  -- TODO
end


return Hud