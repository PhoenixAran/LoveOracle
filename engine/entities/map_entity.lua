local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Collider = require 'engine.components.collider'
local SpriteBank = require 'engine.banks.sprite_bank'
local Entity = require 'engine.entities.entity'
local Combat = require 'engine.components.combat'
local Health = require 'engine.components.health'
local Hitbox = require 'engine.components.hitbox'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'
local SpriteFlasher = require 'engine.components.sprite_flasher'
local SpriteSquisher = require 'engine.components.sprite_squisher'
local InteractionResolver = require 'engine.components.interaction_resolver'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local Physics = require 'engine.physics'
local PhysicsFlags = require 'engine.enums.flags.physics_flags'
local TablePool = require 'engine.utils.table_pool'
local DamageInfo = require 'engine.entities.damage_info'
local Pool = require 'engine.utils.pool'
local Consts = require 'constants'
local bit = require 'bit'
local EntityDebugDrawFlags = require('engine.enums.flags.entity_debug_draw_flags').enumMap
local EffectFactory = require 'engine.entities.effect_factory'


local canCollide = require('engine.entities.bump_box').canCollide

--- default filter for move function in Map_Entities in Physics module
---@param item MapEntity
---@param other any
---@return string?
local function defaultMoveFilter(item, other)
  if canCollide(item, other) then
    if other.isTile and other:isTile() then
      if other:isTopTile() then
        if bit.band(item.collisionTiles, other.tileData.tileType) == 0 then
          return nil
        end
        return 'slide'
      end
      return nil
    end
    return 'slide'
  end
  return nil
end

local function roomEdgeCollisionBoxMoveFilter(item, other)
  if bit.band(PhysicsFlags:get('room_edge').value, other.physicsLayer) ~= 0 then
    return 'slide'
  end
  return nil
end

local GRASS_ANIMATION_UPDATE_INTERVAL = 3

---@class MapEntity : Entity
---@field health Health
---@field movement Movement
---@field groundObserver GroundObserver
---@field combat Combat
---@field hitbox Hitbox
---@field effectSprite AnimatedSpriteRenderer
---@field shadowOffsetX number offset X when effect sprite is playing shadow animation
---@field shadowOffsetY number offset Y when effect sprite is playing shadow animation
---@field rippleOffsetX number offset X when effect sprite is playing ripple animation
---@field rippleOffsetY number offset y when effect sprite is playing ripple animation
---@field grassOffsetX number offset x when effect sprite is playing grass animation
---@field grassOffsetY number offset y when effect sprite is playing grass animation
---@field grassMovementTick integer current number of frames entity has been moving when effect sprite is showing grass effect
---@field interactionResolver InteractionResolver
---@field spriteFlasher SpriteFlasher
---@field spriteSquisher SpriteSquisher
---@field sprite SpriteRenderer|AnimatedSpriteRenderer
---@field roomEdgeCollisionBox Collider
---@field moveCollisions any[]
---@field collisionTiles integer
---@field deathMarked boolean
---@field persistant boolean
---@field syncDirectionWithAnimation boolean
---@field animationDirection4 integer
---@field shadowVisible boolean
---@field rippleVisible boolean
---@field grassVisible boolean
---@field onHurt function
---@field onBump function
---@field moveFilter function filter for move function in Physics:move()\
---@field roomEdgeCollisionBoxMoveFilter function
local MapEntity = Class { __includes = Entity,
  init = function(self, args)
    Entity.init(self, args)

    if args.direction == nil then
      args.direction = Direction4.none
    else
      if type(args.direction) == 'string' then
        args.direction = Direction4[args.direction] or Direction4.none
      else
        args.direction = args.direction
      end
    end

    -- signals
    self:signal('entity_hit')
    self:signal('entity_bumped')
    self:signal('entity_immobolized')
    self:signal('entity_marked_dead')

    self.health = Health(self)
    self.movement = Movement(self)
    self.groundObserver = GroundObserver(self)
    self.combat = Combat(self)
    self.effectSprite = SpriteBank.build('entity_effects', self)
    self.spriteFlasher = SpriteFlasher(self)
    self.spriteSquisher = SpriteSquisher(self)
    self.hitbox = Hitbox(self)

    if args.sprite then
      assert(args.sprite:getType() == 'sprite_renderer' or args.sprite:getType() == 'animated_sprite_renderer', 'Wrong component type provided for sprite')
      self.sprite = args.sprite
    end
    self.interactionResolver = InteractionResolver(self)

    -- component configuration
    self.health:connect('health_depleted', self, '_onHealthDepleted')
    self.hitbox:connect('hitbox_entered', self, '_onHitboxEntered')
    self.hitbox:connect('damaged_other', self, '_onHitboxDamagedOther')
    self.hitbox:connect('resisted', self, '_onHitboxResisted')

    -- NB: this collision box will NOT actually exist in the Physics system
    -- if this is not null, it will only be used to collide with room edges if you want the room edge collider
    -- to be different
    if args.roomEdgeCollisionBox then 
      assert(args.roomEdgeCollisionBox:getType() == 'collider', 'Wrong component type provided for collider')
      self.roomEdgeCollisionBox = args.roomEdgeCollisionBox
    end

    -- table to store collisions that occur when MapEntity:move() is called
    self.moveCollisions = { }
    -- tile types this entity reports collisions with
    self.collisionTiles = 0
    self.moveFilter = defaultMoveFilter
    self.roomEdgeCollisionBoxMoveFilter = roomEdgeCollisionBoxMoveFilter
    -- declarations
    self.deathMarked = false
    self.persistant = false
    self.syncDirectionWithAnimation = true  -- if this is set to true, self.sprite will be assumed to be an AnimatedSpriteRenderer
    self.animationDirection4 = args.direction -- will be used as substrip key if syncDirectionWithAnimation is true

    -- effect sprite animations configurations
    self.shadowVisible = true
    self.shadowOffsetX, self.shadowOffsetY = 0, 0
    self.rippleVisible = true
    self.rippleOffsetX, self.rippleOffsetY = 0, 0
    self.grassVisible = true
    self.grassOffsetX, self.grassOffsetY = 0, 0
    self.grassMovementTick = 0
  end
}

function MapEntity:getType()
  return 'map_entity'
end

function MapEntity:onTransformChanged()
  if self.roomEdgeCollisionBox then
    self.roomEdgeCollisionBox:onTransformChanged()
  end
  if self.hitbox then
    self.hitbox:onTransformChanged()
  end
end

function MapEntity:release()
  lume.clear(self.moveCollisions)
  Entity.release(self)
end

function MapEntity:isPersistant()
  return self.persistant
end

--- unset a tiletype this map entity can collide with
---@param tileType string|string[]
function MapEntity:setCollisionTiles(tileType)
  if type(tileType) == 'table' then
    for _, val in ipairs(tileType) do
      self.collisionTiles = bit.bor(self.collisionTiles, TileTypeFlags:get(val).value)
    end
  else
    self.collisionTiles = bit.bor(self.collisionTiles, TileTypeFlags:get(tileType).value)
  end
end

--- set tiletypes to collide with explicitly with tile type flags
function MapEntity:setCollisionTilesExplicit(flags)
  self.collisionTiles = flags
end

function MapEntity:getCollisionTiles()
  return self.collisionTiles
end

--- set a tiletype this map entity can collide with
---@param tileType string|string[]
function MapEntity:unsetCollisionTile(tileType)
  if type(tileType) == 'table' then
    for _, val in ipairs(tileType) do
      self.collisionTiles = bit.band(self.collisionTiles, bit.bnot(TileTypeFlags:get(val).value))
    end
  else
    self.collisionTiles = bit.band(self.collisionTiles, bit.bnot(TileTypeFlags:get(tileType).value))
  end
end

-- animation stuff

---sets if this map entity should match its direction with it's sprite
---@param value boolean
function MapEntity:setSyncDirectionWithAnimation(value)
  self.syncDirectionWithAnimation = true
end


function MapEntity:doesSyncDirectionWithAnimation()
  return self.syncDirectionWithAnimation
end

function MapEntity:setAnimationDirection4(value)
  self.animationDirection4 = value
  if self:doesSyncDirectionWithAnimation() and self.sprite ~= nil then
    assert(self.sprite:getType() == 'animated_sprite_renderer')
    local animatedSprite = self.sprite
    ---@cast animatedSprite AnimatedSpriteRenderer
    if animatedSprite:getSubstripKey() ~= value then
      animatedSprite:setSubstripKey(value)
    end
  end
end

function MapEntity:getAnimationDirection4()
  return self.animationDirection4
end

---makes sure this entity should be dead. If it should, it marks this entity as death marked
function MapEntity:pollDeath()
  if self.deathMarked and not (self:inHitstun() or self:inKnockback()) then
    self:destroy()
  end
end

-- health component pass throughs
function MapEntity:getMaxHealth()
  return self.health:getMaxHealth()
end

function MapEntity:getHealth()
  return self.health:getHealth()
end

function MapEntity:setHealth(value)
  self.health:setHealth(value)
end

function MapEntity:getArmor()
  return self.health:getArmor()
end

function MapEntity:setArmor(value)
  self.health:setArmor(value)
end

-- movement component pass throughs
function MapEntity:getVector()
  return self.movement:getVector()
end

function MapEntity:setVector(x, y)
  return self.movement:setVector(x, y)
end

function MapEntity:setZVelocity(zVelocity)
  self.movement:setZVelocity(zVelocity)
end

function MapEntity:getDirection4()
  return self.movement:getDirection4()
end

function MapEntity:getDirection8()
  return self.movement:getDirection8()
end

function MapEntity:setVectorAwayFrom(x, y)
  local mx, my = self.movement:getVector()
  self.movement:setVector(vector.sub(mx, my, x, y))
end

function MapEntity:getLinearVelocity()
  return self.movement:getLinearVelocity()
end

function MapEntity:getSpeed()
  return self.movement:getSpeed()
end

function MapEntity:setSpeed(value)
  self.movement:setSpeed(value)
end

function MapEntity:setSpeedScale(value)
  self.movement:setSpeedScale(value)
end

function MapEntity:isInAir()
  if self.movement and self.movement:isEnabled() then
    return self.movement:isInAir()
  end
  return self:getZPosition() > 0
end

function MapEntity:movesWithConveyors()
  return self.movement.movesWithConveyors
end

function MapEntity:movesWithPlatforms()
  return self.movement.movesWithPlatforms
end

---@return number tvx translation vector x
---@return number tvy translation vector y
function MapEntity:move()
  lume.clear(self.moveCollisions)
  local oldX, oldY = self:getPosition()
  local posX, posY = self:getBumpPosition()
  local velX, velY = self:getLinearVelocity()
  velX, velY = vector.add(velX, velY, self:getKnockbackVelocity())
  -- movement due to environment
  if self:movesWithConveyors() and self:onConveyor() then
    velX, velY = vector.add(velX, velY, self.groundObserver.conveyorVelocityX, self.groundObserver.conveyorVelocityY)
  end
  if self:movesWithPlatforms() and self:onPlatform() then
    velX, velY = vector.add(velX, velY, self.groundObserver.movingPlatformX, self.groundObserver.movingPlatformY)
  end

  local goalX, goalY = vector.add(posX, posY, velX, velY)
  local actualX, actualY, cols, len = Physics:move(self, goalX, goalY, self.moveFilter)
  for _, v in ipairs(cols) do
    lume.push(self.moveCollisions, v.other)
  end
  Physics.freeCollisions(cols)
  if self.roomEdgeCollisionBox then
    -- create goal vector value for room edge collision box
    local diffX, diffY = vector.sub(self.x, self.y, self.roomEdgeCollisionBox.x, self.roomEdgeCollisionBox.y)
    local goalX2, goalY2 = vector.sub(actualX, actualY, diffX, diffY)
    local actualX2, actualY2, cols2 = Physics:move(self.roomEdgeCollisionBox, goalX2, goalY2, self.roomEdgeCollisionBoxMoveFilter)
    for _, col in ipairs(cols2) do
      local shouldAddToMoveCollisions = true
      for _, moveCollision in ipairs(self.moveCollisions) do
        if col.other == moveCollision then
          shouldAddToMoveCollisions = false
          break
        end
      end
      if shouldAddToMoveCollisions then
        lume.push(self.moveCollisions, col.other)
      end
    end
    Physics.freeCollisions(cols2)
    actualX, actualY = vector.add(actualX2, actualY2, diffX, diffY)
  end
  self:setPositionWithBumpCoords(actualX, actualY)
  local newX, newY = self:getPosition()
  return vector.sub(oldX, oldY, newX, newY)
end

-- combat component pass throughs
function MapEntity:isIntangible()
  local result = self.combat:isIntangible()
  print(result)
  

  return self.combat:isIntangible()
end

function MapEntity:inHitstun()
  return self.combat:inHitstun()
end

function MapEntity:inKnockback()
  return self.combat:inKnockback()
end

function MapEntity:setIntangibility(value)
  self.combat:setIntangibility(value)
end

function MapEntity:setHitstun(value)
  self.combat:setHitstun(value)
end

function MapEntity:setKnockback(value)
  self.combat:setKnockback(value)
end

function MapEntity:resetCombatVariables()
  self.combat:resetCombatVariables()
end

---@return number, number
function MapEntity:getKnockbackVector()
  return self.combat:getKnockbackVector()
end

function MapEntity:setKnockbackVector(x, y)
  self.combat:setKnockbackVector(x, y)
end

function MapEntity:setKnockbackSpeed(speed)
  self.combat:setKnockbackSpeed(speed)
end

function MapEntity:getKnockbackSpeed()
  return self.combat:getKnockbackSpeed()
end

function MapEntity:getKnockbackVelocity()
  return self.combat:getKnockbackVelocity()
end

-- ground observer pass throughs
function MapEntity:onConveyor()
  return self.groundObserver.onConveyor
end

function MapEntity:onPlatform()
  return self.groundObserver.onPlatform
end

function MapEntity:isInWater()
  return self.groundObserver.inWater
end

function MapEntity:isInLava()
  return self.groundObserver.inLava
end

function MapEntity:isInPuddle()
  return self.groundObserver.inPuddle
end

function MapEntity:isInHole()
  return self.groundObserver.inHole
end

-- interaction resolver pass throughs

---set interaction for when this entity runs into another entity's hitbox with a specific collision tag
---@param tag string collision tag
---@param interaction function
function MapEntity:setInteraction(tag, interaction)
  self.interactionResolver:setInteraction(tag, interaction)
end

function MapEntity:removeInteraction(tag)
  self.interactionResolver:removeInteraction(tag)
end

function MapEntity:resolveInteraction(receiver, sender)
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
function MapEntity:triggerOverrideInteractions(sender)
  return false
end

function MapEntity:reportCollsionWithHitbox(hitbox)
  error('not implemented')
  --self.interactionResolver:reportCollisionWithHitbox(hitbox)
end

function MapEntity:onFallInWater()
  local effect = EffectFactory.createSplashEffect(self:getPosition())
  effect:initTransform()
  self:emit('spawned_entity', effect)
end

function MapEntity:onFallInLava()
  local effect = EffectFactory.createLavaSplashEffect(self:getPosition())
  effect:initTransform()
  self:emit('spawned_entity', effect)
end

function MapEntity:onFallInHole()
  local x, y = self:getPosition()
  local effect = EffectFactory.createFallingObjectEffect(x, y, 'blue')
  effect:initTransform()
  self:emit('spawned_entity', effect)
end

--- hurt this entity
---@param damageInfo DamageInfo|integer
function MapEntity:hurt(damageInfo)
  if self:isIntangible() then
    return
  end
  if type(damageInfo) == 'number' then
    local damage = damageInfo
    damageInfo = DamageInfo()
    damageInfo.damage = damage
  end
  ---@cast damageInfo -integer
  self:resetCombatVariables()
  if damageInfo:applyHitstun() then
    self:setHitstun(damageInfo.hitstunTime)
    -- apply intangible time if it is set
    if damageInfo.intangibilityTime then
      self:setIntangibility(damageInfo.intangibilityTime)
      self:flashSprite(damageInfo.intangibilityTime)
    else
      -- apply default intangibility time
      self:setIntangibility(damageInfo.hitstunTime + 8)
      self:flashSprite(damageInfo.hitstunTime + 8)
    end

  end
  if damageInfo:applyKnockback() then
    self:setKnockback(damageInfo.knockbackTime)
    self:setKnockbackSpeed(damageInfo.knockbackSpeed)
    local ex, ey = self:getPosition()
    self:setKnockbackVector(vector.sub(ex, ey,damageInfo.sourceX, damageInfo.sourceY))
  end

  self.health:takeDamage(damageInfo.damage)
  if self.onHurt then
    self:onHurt(damageInfo)
  end
  self:signal('entity_hit')
end

---TODO bump this entity
---@param sourcePositionX any
---@param sourcePositionY any
---@param duration any
---@param speed any
function MapEntity:bump(sourcePositionX, sourcePositionY, duration, speed)
  -- TODO bump entity
  if self.onBump then
    self:onBump(sourcePositionX, sourcePositionY, duration, speed)
  end
  self:signal('entity_bumped')
end

function MapEntity:onDie()

end

--- calls self:onDie() and then destroys the entity via self:destroy()
function MapEntity:die()
  self:onDie()
  self:destroy()
end

-- sprite flash
---@param duration integer
function MapEntity:flashSprite(duration)
  self.spriteFlasher:flash(duration)
end

function MapEntity:stopSpriteFlash()
  self.spriteFlasher:stop()
end

-- entity effect sprite update
function MapEntity:updateEntityEffectSprite()
  if self.shadowVisible and self:isInAir() then
    if self.effectSprite:getCurrentAnimationKey() ~= 'shadow' or not self.effectSprite:isVisible() then
      self.effectSprite:setOffset(self.shadowOffsetX, self.shadowOffsetY)
      self.effectSprite:play('shadow')
      self.effectSprite:setVisible(true)
      self.effectSprite.alpha = .5
    end
    self.effectSprite:update()
  elseif self.rippleVisible and self.groundObserver.inPuddle then
    if self.effectSprite:getCurrentAnimationKey() ~= 'ripple' or not self.effectSprite:isVisible() then
      self.effectSprite:setOffset(self.rippleOffsetX, self.rippleOffsetY)
      self.effectSprite:play('ripple')
      self.effectSprite:setVisible(true)
      self.effectSprite.alpha = 1
    end
    self.effectSprite:update()
  elseif self.grassVisible and self.groundObserver.inGrass then
    if self.effectSprite:getCurrentAnimationKey() ~= 'grass' or not self.effectSprite:isVisible() then
      self.effectSprite:setOffset(self.grassOffsetX, self.grassOffsetY)
      self.effectSprite:play('grass')
      self.effectSprite:setVisible(true)
      self.effectSprite.alpha = 1
      self.grassMovementTick = 0
      -- initial update when playing the grass animation
      self.effectSprite:update()
    end 
    if self.movement.vectorX ~= 0 or self.movement.vectorY ~= 0 then
      self.grassMovementTick = self.grassMovementTick + 1
      if self.grassMovementTick > GRASS_ANIMATION_UPDATE_INTERVAL then
        self.grassMovementTick = 0
        self.effectSprite:update()
      end
    end
  elseif self.effectSprite:isVisible() then
    self.effectSprite:setOffset(0, 0)
    self.effectSprite:stop()
    self.effectSprite:setVisible(false)
  end
end

function MapEntity:draw()
  local grassEffectPlaying = self.effectSprite:getCurrentAnimationKey() == 'grass'
  if self.effectSprite:isVisible() and not grassEffectPlaying then
    self.effectSprite:draw()
  end
  if self.sprite:isVisible() then
    self.sprite:draw()
  end
  if self.effectSprite:isVisible() and grassEffectPlaying then
    self.effectSprite:draw()
  end
end

--- debug draw
---@param entDebugDrawFlags integer
function MapEntity:debugDraw(entDebugDrawFlags)
  Entity.debugDraw(self, entDebugDrawFlags)
  if bit.band(entDebugDrawFlags, EntityDebugDrawFlags.RoomBox) ~= 0 and self.roomEdgeCollisionBox then
    self.roomEdgeCollisionBox:debugDraw()
  end
  if bit.band(entDebugDrawFlags, EntityDebugDrawFlags.HitBox) ~= 0 and self.hitbox then
    self.hitbox:debugDraw()
  end
end

-- signal callbacks
function MapEntity:_onHealthDepleted()
  self.deathMarked = true
  -- notify entity script
---@diagnostic disable-next-line: undefined-field
  if self.onHealthReduced then
---@diagnostic disable-next-line: undefined-field
    self:onHealthDepleted()
  end
end

-- TODO
function MapEntity:_onHitboxEntered(hitbox)
  self:resolveInteraction(self.hitbox, hitbox)
end

-- TODO
function MapEntity:_onHitboxDamagedOther(hitbox)

end

return MapEntity
