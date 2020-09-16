local Class = require 'lib.class'
local Player = require 'data.player.player'

local PlayerPlayground = Class {
  init = function(self)
    self.player = nil
  end
}

function PlayerPlayground:enter(prev, ...)
  self.player = Player(true, true, { x = 24, y = 24, w = 16, h = 16 })
end

function PlayerPlayground:update(dt)
  self.player:update(dt)
end

function PlayerPlayground:draw()
  self.player:draw()
end

return PlayerPlayground