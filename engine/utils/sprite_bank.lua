local Class = require 'lib.class'
local lume = require 'lib.lume'

local SpriteRendererBuilder = require 'engine.utils.sprite_renderer_builder'
local SpriteAnimationBuilder = require 'engine.utils.sprite_animation_builder'


local SpriteRenderer = require 'engine.components.animated_sprite_renderer'
local AnimatedSpriteRenderer = require 'engine.components.animated_sprite_renderer'
local fh = require 'engine.utils.file_helper'

-- export type
local SpriteBank = { 
  -- holds singular sprite instances
  sprites = { },
  -- holds individual sprite animations
  -- useful for shared animation such as death effects or breaking animations
  animations = { },
  -- holds AnimatedSpriteBuilder instances
  builders = { }
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

function SpriteBank.createSpriteRendererBuilder()
  return SpriteRendererBuilder()
end

function SpriteBank.createSpriteAnimationBuilder()
  return SpriteAnimationBuilder()
end

-- TODO function SpriteBank.createSpriteBuilder()

function SpriteBank.initialize(path)
  path = path or 'data.sprites'
  require(path)(SpriteBank)
end

return SpriteBank