local Class = require 'lib.class'
local lume = require 'lib.lume'

local SpriteBuilder = require 'engine.utils.sprite_builder'
local SpriteRendererBuilder = require 'engine.utils.sprite_renderer_builder'
local SpriteAnimationBuilder = require 'engine.utils.sprite_animation_builder'
local Spriteset = require 'engine.graphics.spriteset'


local SpriteRenderer = require 'engine.components.animated_sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local fh = require 'engine.utils.file_helper'

-- export type
---@class SpriteBank
local SpriteBank = {
  -- holds singular sprite instances
  sprites = { },
  -- holds individual sprite animations
  -- useful for shared animation such as death effects or breaking animations
  animations = { },
  -- holds AnimatedSpriteBuilder instances
  builders = { },
  -- holds SpriteSet instances
  spritesets = { },
}

-- getters and setters for caches
function SpriteBank.registerSprite(key, sprite)
  assert(not SpriteBank.sprites[key], 'SpriteBank already has sprite with key ' .. key)
  SpriteBank.sprites[key] = sprite
end

function SpriteBank.getSprite(key)
  assert(SpriteBank.sprites[key], 'SpriteBank does not have sprite with key ' .. key)
  return SpriteBank.sprites[key]
end

function SpriteBank.registerAnimation(key, spriteAnimation)
  assert(not SpriteBank.animations[key], 'SpriteBank already has SpriteAnimation with key ' .. key)
  SpriteBank.animations[key] = spriteAnimation
end

function SpriteBank.getAnimation(key)
  assert(SpriteBank.animations[key], 'SpriteBank does not have SpriteAnimation with key ' .. key)
  return SpriteBank.animations[key]
end

function SpriteBank.registerSpriteRendererBuilder(key, builder)
  assert(not SpriteBank.builders[key], 'SpriteBank already has SpriteRendererBuilder with key ' .. key)
  SpriteBank.builders[key] = builder
end

function SpriteBank.build(key, entity)
  assert(SpriteBank.builders[key], 'SpriteBank does not have SpriteRendererBuilder with key ' .. key)
  return SpriteBank.builders[key]:build(entity)
end

function SpriteBank.registerSpriteset(spriteset)
  assert(spriteset:getName(), 'SpriteBank cannot register spriteset without a name')
  assert(not SpriteBank.spritesets[spriteset:getName()], 'SpriteBank already has spriteset with key ' .. spriteset:getName())
  SpriteBank.spritesets[spriteset:getName()] = spriteset
end

function SpriteBank.getSpriteset(key)
  assert(SpriteBank.spritesets[key], 'SpriteBank does not have a Spriteset with key ' .. key)
  return SpriteBank.spritesets[key]
end

function SpriteBank.createSpriteRendererBuilder()
  return SpriteRendererBuilder()
end

function SpriteBank.createSpriteAnimationBuilder()
  return SpriteAnimationBuilder()
end

function SpriteBank.createSpriteBuilder()
  return SpriteBuilder()
end

function SpriteBank.createSpriteset(spritesetName, sizeX, sizeY)
  return Spriteset(spritesetName, sizeX, sizeY)
end

function SpriteBank.initialize(path)
  path = path or 'data.sprites'
  require(path)(SpriteBank)
end

function SpriteBank.unload()
  SpriteBank.builders = { }
  
  for _, spriteset in pairs(SpriteBank.spritesets) do
    spriteset:release()
  end
  SpriteBank.spritesets = { }
  
  for _, animation in ipairs(SpriteBank.animations) do
    animation:release()
  end
  
  for _, sprite in pairs(SpriteBank.sprites) do
    sprite:release()
  end
  
  SpriteBank.sprites = { }
end

return SpriteBank