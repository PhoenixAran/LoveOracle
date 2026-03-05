local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local SignalObject = require 'engine.signal_object'
local AssetManager = require 'engine.asset_manager'

---@class Hud
---@field dynamicCurrency number -- used to slowly increment currency count
---@field dynamicHealth number -- used to slowly increment health count
---@field NinePatch NinePatchSprite
local Hud = Class { __includes = SignalObject,
  init = function(self, args)
    SignalObject.init(self)

    self.dynamicCurrency = 0
    self.dynamicHealth = 0
  end
}

function Hud:getType()
  return 'hud'
end

function Hud:initialize()

end

function Hud:update()

end

function Hud:draw()
  -- HUD placeholder
  love.graphics.setColor(50 / 255, 50 / 255, 60 / 255)
  love.graphics.rectangle('fill', 0, 144 - 16, 256, 16)
  love.graphics.setColor(1,1,1)
  local monogram = AssetManager.getFont('game_font')
  love.graphics.setFont(monogram)
  love.graphics.print('HUD Placeholder', 8, 130)
end

return Hud