local Class = require 'lib.class'
local GameConfig = require 'game_config'
local rect = require 'engine.utils.rectangle'
local AssetManager = require 'engine.utils.asset_manager'
local lume = require 'lib.lume'
local console = require 'lib.console'

local Singletons = require 'engine.singletons'
local DisplayHandler = require 'engine.display_handler'
local input = Singletons.input

---@class BaseScreen
---@field drawVersionText love.Text
---@field init function
local BaseScreen = Class {
  init = function(self)
    self.drawVersionText = love.graphics.newText(AssetManager.getFont('base_screen_debug'), 'Ver ' .. GameConfig.version)
  end
}

function BaseScreen:drawFPS()
  local monogram = AssetManager.getFont('base_screen_debug')
  love.graphics.setFont(monogram)
  local fps = ("%d fps"):format(love.timer.getFPS())
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

function BaseScreen:drawMemory()
  local monogram = AssetManager.getFont('base_screen_debug')
  love.graphics.setFont(monogram)
---@diagnostic disable-next-line: redundant-parameter
  local memory = ("%d kbs"):format(collectgarbage("count", 10, 10))
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(memory, 0, 120, 200, 'left')
end

function BaseScreen:drawVersion()
  local monogram = AssetManager.getFont('base_screen_debug')
  love.graphics.setFont(monogram)
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(self.drawVersionText, 160 - self.drawVersionText:getWidth(), 132)
end

if GameConfig.enableQuakeConsole then
  love.log.trace 'Debug console enabled in basescreen'
  function BaseScreen:keypressed(keycode, scancode, isrepeat)
    console.keypressed(keycode)
  end

  function BaseScreen:textinput(key)
    console.textinput(key)
  end
end

return BaseScreen