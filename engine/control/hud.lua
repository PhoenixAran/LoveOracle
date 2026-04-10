local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local SignalObject = require 'engine.signal_object'
local AssetManager = require 'engine.asset_manager'
local SpriteBank = require 'engine.banks.sprite_bank'
local NLay = require 'lib.nlay'
local GameConfig = require 'game_config'
local DisplayHandler = require 'engine.display_handler'

-- TODO implement
---@class Hud : SignalObject
---@field NinePatch NinePatchSprite
---@field player Player
---@field statusBarBorder NinePatchSprite stat bar border nine patch sprite
---@field statusBarFill Sprite black background for stat bar border
---@field healthBarFill Sprite red fill for health bar
---@field hudRect NLay.Constraint the whole bottom HUD area
---@field hudLeftRect NLay.Constraint the left section of the bottom HUD area, used for player health and madness bars
---@field hudCenterRect NLay.Constraint the center section of the bottom HUD area, used for player stamina bar
---@field hudRightRect NLay.Constraint the right section of the bottom HUD area, used for other info such as score or currency
local Hud = Class { __includes = SignalObject,
  init = function(self, args)
    SignalObject.init(self)

    self.statusBarBorder = SpriteBank.createNinePatchSprite('ui_bar_border')
    self.statusBarFill = SpriteBank.getSprite('black_bar_fill')
    self.healthBarFill = SpriteBank.getSprite('health_bar_fill')

    -- Set up NLay layout area
    local uiPadding = 2
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
end

function Hud:update()

end

function Hud:draw()
  -- HUD background
  love.graphics.setColor(184 / 255, 155 / 255, 114 / 255)
  love.graphics.rectangle('fill', 0, 144 - 16, 256, 16)
  love.graphics.setColor(1,1,1)

  -- debug: draw rects
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

  self:drawHealthBar()
end

function Hud:drawHealthBar()
  -- draw our border
  local x, y, w, h = self.hudLeftRect:get()

  -- there is 9 pixels of whitespace on border and bar fill sprites
  local spritePadX = 9
  local spritePadY = 5

  local barX, barY = x, y
  barX, barY = barX - spritePadX, barY - spritePadY
  barX, barY = barX + self.statusBarFill.originX, barY + self.statusBarFill.originY
  self.statusBarFill:draw(barX, barY)

  local maxHealth = self.player.health:getMaxHealth()
  local currentHealth = self.player.health:getHealth()
  local healthRatio = maxHealth > 0 and (currentHealth / maxHealth) or 0
  local fillWidth = math.floor(self.healthBarFill:getWidth() * healthRatio)
  if fillWidth > 0 then
    -- store old scissor
    local oldSx, oldSy, oldSw, oldSh = love.graphics.getScissor()
    local ox, oy = self.healthBarFill:getOrigin()
    local healthSx, healthSy, healthSw, healthSh = DisplayHandler.transformRect(barX - ox, barY - oy, fillWidth, self.healthBarFill:getHeight())
    love.graphics.setScissor(healthSx, healthSy, healthSw, healthSh)
    self.healthBarFill:draw(barX, barY)

    -- restore old scissor
    love.graphics.setScissor(oldSx, oldSy, oldSw, oldSh)
  end

  self.statusBarBorder:draw(barX, barY)



end

-- callbacks
function Hud:onDamageTaken(damageAmount, oldHealth)
  -- TODO
end

function Hud:onMaxHealthChanged(newMaxHealth, oldMaxHealth)
  -- TODO
end

function Hud:onHealthIncreased(newHealth, oldHealth)
  -- TODO
end


return Hud