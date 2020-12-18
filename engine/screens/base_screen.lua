local Class = require 'lib.class'
local gameConfig = require 'game_config'


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
  local version = 'Ver.' .. gameConfig.version
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(version, 95, 132, 200, right)
end

return BaseScreen