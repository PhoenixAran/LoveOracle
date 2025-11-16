local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Entity = require 'engine.entity'
local ProjectileType = require 'engine.enums.projectile_type'
local EffectFactory = require 'engine.entities.effect_factory'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'
local InteractionResolver = require 'engine.components.interaction_resolver'
local Interactions = require 'engine.entities.interactions'
local Hitbox = require 'engine.components.hitbox'
local CollisionTag = require 'engine.enums.collision_tag'
local bit = require 'bit'

local Physics = require 'engine.physics'
local canCollide = require('engine.entities.bump_box')

local function defaultMoveFilter(item, other)
  if canCollide(item, other) then
    if other.isTile and other:isTile() then
      if bit.band(item.collisionTiles, other.tileData.tileType) == 0 then
        return nil
      end
    end

    return 'touch'
  end

  return nil
end

---@class Projectile : Entity
---@field projectileType ProjectileType
---@field crashAnimation string?
---@field bounceOnCrash boolean
---@field movement Movement
---@field hitbox Hitbox
---@field interactionResolver InteractionResolver
---@field collisionTiles integer
---@field owner Entity?
local Projectile = Class {
  ---@param self Projectile
  ---@param args table
  init = function(self, args)
    -- Initialization code here
    self.projectileType = args.projectileType or ProjectileType.physical
    self.crashAnimation = args.crashAnimation
    self.bounceOnCrash = args.bounceOnCrash or false
    self.owner = args.owner

    self.movement = Movement(self)
    self.hitbox = Hitbox(self)
    self.interactionResolver = InteractionResolver(self)

    self.hitbox:connect('hitbox_entered', self, 'onHitboxEntered')
  end
}

function Projectile:getType()
  return 'projectile'
end

function Projectile:setVector(x, y)
  self.movement:setVector(x, y)
end

function Projectile:getProjectileType()
  return self.projectileType
end

function Projectile:getOwner()
  return self.owner
end

function Projectile:setOwner(owner)
  self.owner = owner
end

---@param rebounded boolean
function Projectile:crash(rebounded)
  local px, py = self:getPosition()
  if self.crashAnimation ~= nil then
    -- create crash effect
    ---@type EffectEntity
    local effect
    if self.bounceOnCrash then
      effect = EffectFactory.createEffectEntity({
        x = px,
        y = py,
        time = 533,
        effectAnimation = self.crashAnimation
      })
      local mx, my = self.movement:getVector()
      effect:setVector(-mx, -my)
      effect:setZVelocity(1)
      effect:setGravity(4.2) -- think this might be 4.2 instead?
    else
      effect = EffectFactory.createEffectEntity({
        x = px,
        y = py,
        effectAnimation = self.crashAnimation
      })
    end
    self:emit('spawned_entity', effect)
  else
    self:destroy()
  end

  self:onCrash()
end

function Projectile:intercept()
  self:destroy()
  return true
end

function Projectile:deflect()
  if self.projectileType ~= ProjectileType.notDeflectable then
    -- TODO play sound
    self:intercept()
  end
end

function Projectile:onCrash()
end

function Projectile:update()
  self.movement:update()
  local px, py = self:getBumpPosition()
  local velX, velY = self.movement:getLinearVelocity()
  local x, y, cols = Physics:move(self, px + velX, py + velY, defaultMoveFilter)

  for _, col in ipairs(cols) do
    local other = col.other
    if other.isTile and other:isTile() then
      ---@type Tile tile
      local tile = other
      if bit.band(self.collisionTiles, tile:getTileType()) ~= 0 then
        self:onCrash()
        -- TODO tile onHitByProjectile or something similar should go here
      end
    end
  end

  Physics.freeCollisions(cols)
  self:setPositionWithBumpCoords(x, y)
end


function Projectile:onHitboxEntered(hitbox)
  self.interactionResolver:resolveInteraction(self.hitbox, hitbox)
end


return Projectile