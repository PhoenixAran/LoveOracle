local Class = require 'lib.class'
local lume = require 'lib.lume'
local NLay = require 'lib.nlay'
local SpriteBank = require 'engine.banks.sprite_bank'
local Input = require('engine.singletons').input
local NLay = require 'lib.nlay'
local GameConfig = require 'game_config'
local AssetManager = require 'engine.asset_manager'
local Menu = require 'engine.menu.menu'


---@class MenuInventory : Menu
---@field lastRoomState GameState? the last room state that was active. Used to pass into the inventory game state when it is opened from a room state, so that the inventory can be drawn over the gameplay screen
---@field itemPanel NinePatchSprite the panel that items are drawn on in the inventory
---@field itemPanelRect NLay.Constraint
---@field itemDetailsPanel NinePatchSprite the panel that item details are drawn on in the inventory
---@field itemDetailsPanelRect NLay.Constraint
local MenuInventory = Class { __includes = Menu,
  init = function(self)
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
  end
}

function MenuInventory:getType()
  return 'menu_inventory'
end

function MenuInventory:drawPanel(rectConstraint, panelSprite, panelLabel, xPadding)
  -- TODO make NinePatchSprite draw method take width and height?
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
    local font = AssetManager.getFont('ui_panel_label')
    love.graphics.setFont(font)

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

function MenuInventory:update()

end


function MenuInventory:draw()
  if self.lastRoomState then
    self.lastRoomState:draw()
  end
  local font = AssetManager.getFont('game_font')
  love.graphics.setFont(font)

  self:drawPanel(self.itemPanelRect, self.itemPanel, 'ITEMS', 12)
  self:drawPanel(self.itemDetailsPanelRect, self.itemDetailsPanel)
end




return MenuInventory