local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local MoverEntity = require 'engine.entities.mover_entity'
local ProjectileType = require 'engine.enums.projectile_type'
local EffectFactory = require 'engine.entities.effect_factory'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'
local InteractionResolver = require 'engine.components.interaction_resolver'
local Interactions = require 'engine.entities.interactions'
local Hitbox = require 'engine.components.hitbox'
local CollisionTag = require 'engine.enums.collision_tag'
local bit = require 'bit'
local AnimationDirectionSyncMode = require 'engine.enums.animation_direction_sync_mode'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'


local Physics = require 'engine.physics'
local canCollide = require('engine.entities.bump_box').canCollide
--- default filter for move function in Map_Entities in Physics module
---@param item MoverEntity
---@param other any
---@return string?
local function defaultProjectileMoveFilter(item, other)
  if canCollide(item, other) then
    if other.isTile and other:isTile() then
      if other:isTopTile() then
        if bit.band(item.collisionTiles, other.tileData.tileType) == 0 then
          return nil
        end
        return 'touch'
      end
      return nil
    end
    return 'touch'
  end
  return nil
end

---@class Projectile : MoverEntity
---@field projectileType ProjectileType
---@field crashAnimation string?
---@field bounceOnCrash boolean
---@field movement Movement
---@field hitbox Hitbox
---@field interactionResolver InteractionResolver
---@field collisionTiles integer
---@field sprite SpriteRenderer|AnimatedSpriteRenderer
---@field owner Entity?
---@field animDirectionSyncMode AnimationDirectionSyncMode
---@field animDirection integer?
---@field collisions any[]
local Projectile = Class { __includes = MoverEntity,
  ---@param self Projectile
  ---@param args table
  init = function(self, args)
    -- Initialization code here
    MoverEntity.init(self)
    self.projectileType = args.projectileType or ProjectileType.physical
    self.crashAnimation = args.crashAnimation
    self.bounceOnCrash = args.bounceOnCrash or false
    self.animDirectionSyncMode = args.animDirectionSyncMode or AnimationDirectionSyncMode.dir4
    self.animDirection = args.animDirection or nil
    self.owner = args.owner or nil

    self.movement = Movement(self)
    self.hitbox = Hitbox(self)
    self.interactionResolver = InteractionResolver(self)
    self.collisions = { }
    self.collisionTiles = 0


    self.hitbox:connect('hitbox_entered', self, 'onHitboxEntered')

    self.moveFilter = defaultProjectileMoveFilter
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
      local mx, my = vector.mul(-1, self.movement:getVector())
      effect:setZVelocity(1)
      effect:setGravity(4.2) -- think this might be 4.2 instead?
      -- TODO have movement stuff without components in effect class
    else
      effect = EffectFactory.createEffectEntity({
        x = px,
        y = py,
        effectAnimation = self.crashAnimation
      })
    end
    self:emit('spawned_entity', effect)
  end
  
  self:onCrash()
  self:destroy()
end

function Projectile:intercept()
  self:crash(true)
  return true
end

function Projectile:deflect()
  if self.projectileType ~= ProjectileType.notDeflectable then
    -- TODO play sound
    self:intercept()
  end
end

function Projectile:updateAnimationDirection()
  if self.animDirectionSyncMode == AnimationDirectionSyncMode.dir4 then
    self.animDirection = self.movement:getDirection4()
  elseif self.animDirectionSyncMode == AnimationDirectionSyncMode.dir8 then
    self.animDirection = self.movement:getDirection8()
  end
end

function Projectile:onCrash()
end

function Projectile:onCollideSolid(solid)
  self:crash(true)
end 

function Projectile:onAwake()
  self:updateAnimationDirection()
end

function Projectile:update()
  self.movement:update()
  self.hitbox:update()

  
  local tvx, tvy, cols = self:move()
  if tvx == 0 and tvy == 0 and lume.any(cols) then 
    self:onCollideSolid(cols[1])
  end
end

function Projectile:draw()
  self.sprite:draw()
end

--- interaction resolver api

---set interaction for when this entity runs into another entity's hitbox with a specific collision tag
---@param tag string collision tag
---@param interaction function
function Projectile:setInteraction(tag, interaction)
  self.interactionResolver:setInteraction(tag, interaction)
end

function Projectile:removeInteraction(tag)
  self.interactionResolver:removeInteraction(tag)
end

function Projectile:resolveInteraction(receiver, sender)
  local tag = sender:getCollisionTag()
  if self.interactionResolver:hasInteraction(tag) then
    self.interactionResolver:resolveInteraction(receiver, sender)
  end
end

--- this method is used when the entity is not configured to automatically respond to
--- a given hitbox type. This allows the entity to check if any of it's items can
--- protect it from the sender. This is usually just used on the player since players
--- are not automatically set to collide with monsters, but they should still be able to block
--- attacks with a shield or parry attacks with a sword
--- @param sender Hitbox the hitbox that the entity is colliding with
--- @return boolean
function Projectile:triggerOverrideInteractions(sender)
  return false
end

-- signal callbacks
function Projectile:onHitboxEntered(hitbox)
  self.interactionResolver:resolveInteraction(self.hitbox, hitbox)
end 

return Projectile