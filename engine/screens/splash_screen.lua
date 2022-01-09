local Class = require 'lib.class'
local splashModule = require 'lib.one_ten_one'

local SplashScreen = Class {
  init = function(self, nextScreen)
    self.nextScreen = nextScreen
    self.splash = nil
  end
}

function SplashScreen:enter(prev, ...)
  self.splash = splashModule.new({background = {0, 0, 0}})
  local nextScreen = self.nextScreen
  function self.splash:onDone()
    screenManager:push(require(nextScreen)())
  end
end

function SplashScreen:update(dt)
  self.splash:update(dt)
end

function SplashScreen:draw()
  self.splash:draw()
end

function SplashScreen:keypressed(key)
  self.splash:skip()
end

return SplashScreen