local Class = require 'lib.class'
local lume = require 'lib.lume'

-- meant to be shared between multiple tile instances
local TileSpriteRenderer = Class {
  init = function(self, sprite, animated)
    self.sprite = sprite
    self.animated = animated
    -- these two are used if sprite is a sprite animation instance
    self.currentTick = 1
    self.currentFrameIndex = 1
  end
}

function TileSpriteRenderer:getType()
  return 'tile_sprite_renderer'
end

-- This should only be called if this sprite is animated
function TileSpriteRenderer:update(dt)
  if self.animated then
    local currentFrame = self.sprite[self.currentFrameIndex]
    local spriteFrames = self.sprite:getSpriteFrames()
    if currentFrame:getDelay() < self.currentTick then
      self.currentTick = 1
      self.currentFrameIndex = self.currentFrameIndex + 1
      if #spriteFrames < self.currentFrameIndex then
        -- treats every animation like a cycle animation
        self.currentFrameIndex = 1
      end
    end
  end
end

function TileSpriteRenderer:draw(x, y)
  if self.animated then
    local currentFrame = self.sprite[self.currentFrameIndex]
    local sprite = currentFrame:getSprite()
    sprite:draw(x, y)
  else
    self.sprite:draw(x, y)
  end
end

return TileSpriteRenderer