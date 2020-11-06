local Class = require 'lib.class'
local Component = require 'entities.component'
local lume = require 'lib.lume'


local SpriteFlasher = Class { __includes = Component,
  init = function(self)
    self.tick = 0
    self.interval = 12
    self.color = { 0, 0, 0, .5 }
    self.sprites = { }
  end
}


function SpriteFlasher:getType()
  return 'spriteflasher'
end

function SpriteFlasher:addSprite()
  
end


function SpriteFlasher:reset()
  
end

if pool then
  pool.register('spriteflasher', SpriteFlasher)
end

return SpriteFlasher