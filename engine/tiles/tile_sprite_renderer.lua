local Class = require 'lib.class'
local lume = require 'lib.lume'
local SpriteAnimationUpdater = require 'engine.graphics.sprite_animation_updater'

-- meant to be shared between multiple tile instances
---@class TileSpriteRenderer
---@field spriteAnimationUpdater SpriteAnimationUpdater
---@field sprite Sprite|SpriteAnimation
---@field currentTick integer
---@field currentFrameIndex integer
local TileSpriteRenderer = Class {
  init = function(self, sprite, animated)
    self.sprite = sprite
    if animated then
      self.spriteAnimationUpdater = SpriteAnimationUpdater()
      self.spriteAnimationUpdater:play(sprite)
    end
    -- these two are used if sprite is a list of sprite frames
    self.currentTick = 1
    self.currentFrameIndex = 1
  end
}

function TileSpriteRenderer:getType()
  return 'tile_sprite_renderer'
end

function TileSpriteRenderer:isAnimated()
  return self.spriteAnimationUpdater ~= nil
end

function TileSpriteRenderer:resetSpriteAnimation()
  assert(self.spriteAnimationUpdater, 'Cannot reset sprite animation on a non animated sprite')
  self.spriteAnimationUpdater:reset()
end

-- This should only be called if this sprite is animated
function TileSpriteRenderer:update()
  if self.spriteAnimationUpdater then
    self.spriteAnimationUpdater:update()
  end
end

function TileSpriteRenderer:draw(x, y)
  if self.spriteAnimationUpdater then
    self.spriteAnimationUpdater:getCurrentSprite():getSprite():draw(x, y)
  else
    self.sprite:draw(x, y)
  end
end

return TileSpriteRenderer