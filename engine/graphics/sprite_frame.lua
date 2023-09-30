local Class = require 'lib.class'

--- used in SpriteAnimation class
---@class SpriteFrame
---@field sprite Sprite|ColorSprite|PrototypeSprite|CompositeSprite|EmptySprite
---@field delay integer
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

function SpriteFrame:release()
  self.sprite:release()
end

return SpriteFrame