local Class = require 'lib.class'
local lume = require 'lib.lume'

-- meant to be shared between multiple tile instances
local TileSpriteRenderer = Class {
  init = function(self, sprite, animated)
    self.sprite = sprite
    self.animated = animated
    -- these two are used if sprite is a list of sprite frames
    self.currentTick = 1
    self.currentFrameIndex = 1
  end
}

function TileSpriteRenderer:getType()
  return 'tile_sprite_renderer'
end

function TileSpriteRenderer:isAnimated()
  return self.animated
end

function TileSpriteRenderer:resetSpriteAnimation()
  assert(self.animated)
  self.currentTick = 1
  self.currentFrameIndex = 1
end

-- This should only be called if this sprite is animated
function TileSpriteRenderer:update(dt)
  if self.animated then
    local currentFrame = self.sprite[self.currentFrameIndex]
    local spriteFrames = self.sprite
    self.currentTick = self.currentTick + 1
    if currentFrame:getDelay() < self.currentTick then
      self.currentTick = 1
      self.currentFrameIndex = self.currentFrameIndex + 1
      if lume.count(spriteFrames) < self.currentFrameIndex then
        -- treats every animation like a cycle animation
        self.currentFrameIndex = 1
      end
    end
  end
end

function TileSpriteRenderer:draw(x, y)
  if self.animated then
    local index = self.currentFrameIndex
    local currentFrame = self.sprite[index]
    local sprite = currentFrame.sprite
    sprite:draw(x, y)
  else
    self.sprite:draw(x, y)
  end
end

return TileSpriteRenderer