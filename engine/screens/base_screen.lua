local Class = require 'lib.class'
local GameConfig = require 'game_config'
local rect = require 'engine.utils.rectangle'
local AssetManager = require 'engine.utils.asset_manager'

local BaseScreen = Class {
  init = function(self)
    self.drawVersionText = love.graphics.newText(AssetManager.getFont('monogram'), 'Ver ' .. GameConfig.version)
  end
}

function BaseScreen:drawFPS()
  local monogram = AssetManager.getFont('monogram')  
  love.graphics.setFont(monogram)
  local fps = ("%d fps"):format(love.timer.getFPS())
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

function BaseScreen:drawMemory()
  local monogram = AssetManager.getFont('monogram')
  love.graphics.setFont(monogram)
  local memory = ("%d kbs"):format(collectgarbage("count"))
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(memory, 0, 120, 200, 'left')
end

function BaseScreen:drawVersion()
  local monogram = AssetManager.getFont('monogram')
  love.graphics.setFont(monogram)
  local version = 'Ver ' .. GameConfig.version
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.drawVersionText, 160 - self.drawVersionText:getWidth(), 132)
end

function BaseScreen:mouseClickInGame(x, y)
  if not input:pressed('leftClick') then
    return false
  end
  if x == nil or y == nil then
    x, y = love.mouse.getPosition()
  end
  local mx = monocle.x
  local my = monocle.y
  local width = monocle.windowWidth * monocle.scale
  local height = monocle.windowHeight * monocle.scale
  return rect.containsPoint(mx, my, width, height, x, y)
end

return BaseScreen