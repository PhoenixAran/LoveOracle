local Class = require 'lib.class'
local GameConfig = require 'game_config'
local rect = require 'engine.utils.rectangle'
local AssetManager = require 'engine.utils.asset_manager'
local lume = require 'lib.lume'
local console = nil
if GameConfig.enableQuakeConsole then
  console = require 'lib.console'
end

local BaseScreen = Class {
  init = function(self)
    self.drawVersionText = love.graphics.newText(AssetManager.getFont('monogram'), 'Ver ' .. GameConfig.version)
    self.consoleEnabled = false
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

function BaseScreen:getMousePositionInCanvas()
  local x, y = love.mouse.getPosition()
  local mx = monocle.x
  local my = monocle.y
  local width = monocle.windowWidth * monocle.scale
  local height = monocle.windowHeight * monocle.scale 
  x = x - mx
  y = y - my 
  x = x / monocle.scale
  y = y / monocle.scale
  return x, y
end

if console then
  print 'Debug console enabled in basescreen!'
  function BaseScreen:keypressed(keycode, scancode, isrepeat)
    if keycode == '`' then
      if self.consoleEnabled then
        print('DISABLING CONSOLE')
        self.consoleEnabled = false
        love.keyboard.setKeyRepeat(false)
      else
        print('ENABLING CONSOLE')
        self.consoleEnabled = true
        love.keyboard.setKeyRepeat(true)
      end
    elseif self.consoleEnabled then
      console.keypressed(keycode)
    end
  end

  function BaseScreen:textinput(key)
    if self.consoleEnabled and key ~= '`' then
      console.textinput(key)
    end
  end
end

return BaseScreen