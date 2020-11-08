local Class = require 'lib.class'

local SpriteFrame = Class {
  init = function(self, sprite, delay)
    if delay == nil then delay = 6 end
    self.sprite = sprite
    self.delay = delay
  end
}

function SpriteFrame:getType()
  return 'sprite_frame'
end

function SpriteFrame:getDelay()
  return self.delay
end

function SpriteFrame:getSprite()
  return self.sprite
end


return SpriteFrame