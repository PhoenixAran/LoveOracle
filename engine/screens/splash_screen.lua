local Class = require 'lib.class'
local screenManager = require('engine.singletons').screenManager

---@class SplashScreen
local SplashScreen = Class {
  init = function(self, nextScreen)
  end
}

function SplashScreen:enter(prev, ...)

end

function SplashScreen:update()
end

function SplashScreen:draw()
end

function SplashScreen:keypressed(key)
end

return SplashScreen