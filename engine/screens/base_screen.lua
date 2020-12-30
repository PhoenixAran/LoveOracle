local Class = require 'lib.class'
local gameConfig = require 'game_config'
local rect = require 'engine.utils.rectangle'

local BaseScreen = Class {
  init = function(self)
    
  end
}

function BaseScreen:drawFPS()
  local monogram = assetManager.getFont('monogram')  
  love.graphics.setFont(monogram)
  local fps = ("%d fps"):format(love.timer.getFPS())
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

function BaseScreen:drawMemory()
  local monogram = assetManager.getFont('monogram')
  love.graphics.setFont(monogram)
  local memory = ("%d kbs"):format(collectgarbage("count"))
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(memory, 0, 120, 200, 'left')
end

function BaseScreen:drawVersion()
  local monogram = assetManager.getFont('monogram')
  love.graphics.setFont(monogram)
  local version = 'Ver ' .. gameConfig.version
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(version, 95, 132, 200, right)
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