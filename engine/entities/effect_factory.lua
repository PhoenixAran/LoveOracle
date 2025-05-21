local EffectEntity = require 'engine.entities.effect_entity'
local SpriteBank = require 'engine.banks.sprite_bank'
-- TODO sound

-- helper class template
---@class EffectEntityArgs
---@field effectAnimation string|SpriteAnimation|nil the effect animation
---@field time number|nil the time in ms the effect should last. This will override the effectAnimation duration if provided

---module that helps creates Effect Entities
---@class EffectFactory
local EffectFactory = { }

---creates a custom effect entity with given parameters
---@param args EffectEntityArgs
---@return EffectEntity the created effect entity
function EffectFactory.createEffectEntity(args)
  if args.effectAnimation == nil and args.time == nil then
    error('Effect animation, an effectAnimation, time, or sound must be provided. You cannot provide nil for all of them')
  end
  if type(args.effectAnimation) == 'string' then
    args.effectAnimation = SpriteBank.getAnimation(args.effectAnimation)
  end

  local effectEntity = EffectEntity(args)
  effectEntity:initTransform()

  return effectEntity
end

-- specific ones declared below

--- creates a splash effect entity
---@param x number the x position of the effect
---@param y number the y position of the effect
---@param time number? the time in ms the effect should last. This will override the effectAnimation duration if provided
function EffectFactory.createSplashEffect(x, y, time)
  local effect = EffectFactory.createEffectEntity({
    x = x,
    y = y,
    effectAnimation = 'effect_splash',
    time = time
  })
  effect:initTransform()
  return effect
end


return EffectFactory