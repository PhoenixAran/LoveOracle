local Class = require 'lib.class'
local lume = require 'lib.lume'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'

---@class SpriteRendererBuilder
---@field type string
---@field animations table<string, SpriteAnimation>
---@field sprite Sprite
---@field deferredSprite any
---@field offsetX number
---@field offsetY number
---@field followZ boolean
local SpriteRendererBuilder = Class {
  init = function(self)
    -- by default this is used to configure an animated sprite
    -- its the most common use case
    self.type = 'animated_sprite_renderer'
    -- used if type is 'animatedsprite'
    self.animations = { }

    -- used if type is 'sprite'
    self.sprite = nil
    self.deferredSprite = nil

    -- shared between animatedsprite and sprite
    self.offsetX, self.offsetY = 0, 0
    self.followZ = true
  end
}

---@return string
function SpriteRendererBuilder:getType()
  return 'sprite_renderer_builder'
end

---sets default animation for SpriteRenderer
---@param value string
function SpriteRendererBuilder:setDefaultAnimation(value)
  self.defaultAnimation = value
end

---builds SpriteRenderer
---@param entity Entity
---@return SpriteRenderer|AnimatedSpriteRenderer
function SpriteRendererBuilder:build(entity)
  if self.type == 'sprite_renderer' then
      -- use sprite in SpriteBuilder instance
      return SpriteRenderer(entity, {
        sprite = self.sprite,
        offsetX = self.offsetX,
        offsetY = self.offsetY,
        followZ = self.followZ
      })
  elseif self.type == 'animated_sprite_renderer' then
    local animations = { }
    animations = lume.merge(animations, self.animations)
    return AnimatedSpriteRenderer(entity, {
      animations = animations,
      defaultAnimation = self.defaultAnimation,
      offsetX = self.offsetX,
      offsetY = self.offsetY,
      followZ = self.followZ
    })
  else
    error('SpriteType out of range')
  end
end

---@param key string
---@param animation SpriteAnimation
function SpriteRendererBuilder:addAnimation(key, animation)
  if self.animations[key] then
    error(tostring(key) .. ' animation already exists in sprite builder')
  end
  self.animations[key] = animation
end

---sets if the SpriteRenderer should follow the Z position of the parent Entity
---@param value any
function SpriteRendererBuilder:setFollowZ(value)
  self.followZ = value
end

return SpriteRendererBuilder