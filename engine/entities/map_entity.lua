local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local Collider = require 'engine.components.collider'
local SpriteBank = require 'engine.utils.sprite_bank'
local Entity = require 'engine.entities.entity'
local Combat = require 'engine.components.combat'
local Health = require 'engine.components.health'
local Movement = require 'engine.components.movement'
local GroundObserver = require 'engine.components.ground_observer'
local SpriteFlasher = require 'engine.components.sprite_flasher'
local Direction4 = require 'engine.enums.direction4'
local Direction8 = require 'engine.enums.direction8'
local TileTypeFlags = require 'engine.enums.flags.tile_type_flags'
local Physics = require 'engine.physics'
local TablePool = require 'engine.utils.table_pool'
local DamageInfo = require 'engine.entities.damage_info'
local Pool = require 'engine.utils.pool'

local canCollide = require('engine.entities.bump_box').canCollide

--- default filter for move function in Physics module
---@param item MapEntity
---@param other any
---@return string?
local function defaultMoveFilter(item, other)
  if canCollide(item, other) then
    if other:isTile() then
      if bit.band(item.collisionTiles, other.tileData.tileType) == 0 then
        return nil
      end
    end
    return 'slide'
  end
  return nil
end

---@class MapEntity : Entity
---@field health Health
---@field movement Movement
---@field groundObserver GroundObserver
---@field combat Combat
---@field effectSprite AnimatedSpriteRenderer
---@field spriteFlasher SpriteFlasher
---@field sprite SpriteRenderer | AnimatedSpriteRenderer
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
---@field moveFilter function filter for move function in Physics:move()
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
    self:signal('entityDestroyed')
    self:signal('entityCreated')
    self:signal('entityHit')
    self:signal('entityBumped')
    self:signal('entityImmobolized')
    self:signal('entityMarkedDead')

    self.health = Health(self)
    self.movement = Movement(self)
    self.groundObserver = GroundObserver(self)
    self.combat = Combat(self)
    self.effectSprite = SpriteBank.build('entity_effects', self)
    self.spriteFlasher = SpriteFlasher(self)
    self.sprite = nil   -- declare this yourself

    -- this collision box will NOT actually exist in the Physics system
    -- if this is not null, it will only be used to collide with room edges if you want the room edge collider
    -- to be different
    self.roomEdgeCollisionBox = nil

    -- table to store collisions that occur when MapEntity:move() is called
    self.moveCollisions = { }
    -- tile types this entity reports collisions with
    self.collisionTiles = 0
    self.moveFilter = defaultMoveFilter

    -- declarations
    self.deathMarked = false
    self.persistant = false
    self.syncDirectionWithAnimation = true  -- if this is set to true, self.sprite will be assumed to be an AnimatedSpriteRenderer
    self.animationDirection4 = args.direction -- will be used as substrip key if syncDirectionWithAnimation is true
    -- shadow, ripple, and grass effects
    -- TODO finish ripple and grass effects
    self.shadowVisible = true
    --self.shadowOffsetX, self.shadowOffsetY = 0, 0
    self.rippleVisible = false
    --self.rippleOffsetX, self.rippleOffsetY = 0, 0
    self.grassVisible = false
    --self.grassOffsetX, self.grassOffsetY = 0, 0
  end
}

function MapEntity:getType()
  return 'map_entity'
end

function MapEntity:getCollisionTag()
  return 'map_entity'
end

function MapEntity:onTransformChanged()
  if self.roomEdgeCollisionBox then
    self.roomEdgeCollisionBox:onTransformChanged()
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
function MapEntity:setCollisionTile(tileType)
  if type(tileType) == 'table' then
    for _, val in ipairs(tileType) do
      self.collisionTiles = bit.bor(self.collisionTiles, TileTypeFlags:get(val).value)
    end
  else
    self.collisionTiles = bit.bor(self.collisionTiles, TileTypeFlags:get(tileType).value)
  end
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
    if self.sprite:getSubstripKey() ~= value then
      self.sprite:setSubstripKey(value)
    end
  end
end

function MapEntity:getAnimationDirection4()
  return self.animationDirection4
end

---makes sure this entity should be dead. If it should, it marks this entity as death marked
function MapEntity:pollDeath()
  if self.deathMarked and not (self:inHitstun() or self:inKnockback()) then
    self:die()
  end
end

function MapEntity:die()
  self:release()
  self:emit('entityDestroyed')
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

function MapEntity:getLinearVelocity(dt)
  return self.movement:getLinearVelocity(dt)
end

function MapEntity:getSpeed()
  return self.movement:getSpeed()
end

function MapEntity:setSpeed(value)
  self.movement:setSpeed(value)
end

function MapEntity:isInAir()
  if self.movement and self.movement:isEnabled() then
    return self.movement:isInAir()
  end
  return self:getZPosition() > 0
end

function MapEntity:isOnGround()
  return not self:isInAir()
end

-- ---carries out the movement designated by the Movement Component
-- ---@param dt number
-- ---@return number tvx translation vector x
-- ---@return number tvy translation vector y
-- function MapEntity:move(dt)
--   lume.clear(self.moveCollisions)
--   local posX, posY = self:getPosition()
--   local velX, velY = self.movement:getLinearVelocity(dt)
--   local kx, ky = self:getKnockbackVelocity(dt)
--   velX, velY = vector.add(velX, velY, kx, ky)
--   local bx = self.x + velX
--   local by = self.y + velY
--   local bw = self.w
--   local bh = self.h
--   local neighbors = Physics.boxcastBroadphase(self, bx, by, bw, bh)
--   for i, neighbor in ipairs(neighbors) do
--     if self:reportsCollisionsWith(neighbor) then
--       local shouldCarryOutCollision = true
--       if neighbor:isTile() then
--         ---@type TileData
--         local tileData = neighbor.tileData
--         shouldCarryOutCollision = bit.band(self.collisionTiles, tileData.tileType) ~= 0
--       end
--       if shouldCarryOutCollision then
--         local collided, mtvX, mtvY, normX, normY = self:boxCast(neighbor, velX, velY)
--         if collided then
--           -- hit, back off our motion
--           velX, velY = vector.sub(velX, velY, mtvX, mtvY)
--           -- add other box to moveCollisions table
--           lume.push(self.moveCollisions, neighbor)
--         end
--       end
--     end
--   end
--   TablePool.free(neighbors)
--   if self.roomEdgeCollisionBox then
--     bx = self.roomEdgeCollisionBox.x + velX
--     by = self.roomEdgeCollisionBox.y + velY
--     bw = self.roomEdgeCollisionBox.w
--     bh = self.roomEdgeCollisionBox.h
--     neighbors = Physics.boxcastBroadphase(self.roomEdgeCollisionBox, bx, by, bw, bh)
--     for i, neighbor in ipairs(neighbors) do
--       if self.roomEdgeCollisionBox:reportsCollisionsWith(neighbor) then
--         local collided, mtvX, mtvY, normX, normY = self.roomEdgeCollisionBox:boxCast(neighbor, velX, velY)
--         if collided then
--           -- hit from roomEdge, back off from motion
--           velX, velY = vector.sub(velX, velY, mtvX, mtvY)
--           -- add to moveCollisions table if it is not present
--           local shouldAddToMoveCollisions = true
--           for _, other in ipairs(self.moveCollisions) do
--             if other == neighbor or self == neighbor then
--               shouldAddToMoveCollisions = false
--               break
--             end
--           end
--           if shouldAddToMoveCollisions then
--             lume.push(self.moveCollisions, neighbor)
--           end
--         end
--       end
--     end
--     TablePool.free(neighbors)
--   end
--   local oldX, oldY = self:getPosition()
--   self:setPosition(posX + velX, posY + velY)
--   Physics.update(self)
--   local newX, newY = self:getPosition()
--   return vector.sub(oldX, oldY, newX, newY)
-- end

---@param dt number delta time
---@return number tvx translation vector x
---@return number tvy translation vector y
function MapEntity:move(dt)
  lume.clear(self.moveCollisions)
  local oldX, oldY = self:getPosition()
  local posX, posY = self:getBumpPosition()
  local velX, velY = self.movement:getLinearVelocity(dt)
  velX, velY = vector.add(velX, velY, self:getKnockbackVelocity(dt))
  local goalX, goalY = vector.add(posX, posY, velX, velY)
  local actualX, actualY, cols, len = Physics:move(self, goalX, goalY, self.moveFilter)
  for _, v in ipairs(cols) do
    lume.push(self.moveCollisions, v.other)
  end
  Physics.freeCollisions(cols)
  if self.roomEdgeCollisionBox then
    -- create goal vector value for room edge collision box
    local diffX, diffY = vector.sub(self.x, self.y, self.roomEdgeCollisionBox.x + self.roomEdgeCollisionBox.offsetX, self.roomEdgeCollisionBox.y + self.roomEdgeCollisionBox.offsetY)
    local goalX2, goalY2 = vector.sub(actualX, actualY, diffX, diffY)
    local actualX2, actualY2, cols, len = Physics:move(self.roomEdgeCollisionBox, goalX2, goalY2, self.moveFilter)
    for i, col in ipairs(cols) do
      local shouldAddToMoveCollisions = true
      for j, moveCollision in ipairs(self.moveCollisions) do
        if col.other == moveCollision then
          shouldAddToMoveCollisions = false
          break
        end
      end
      if shouldAddToMoveCollisions then
        lume.push(self.moveCollisions, col.other)
      end
    end
    Physics.freeCollisions(cols)
    actualX, actualY = vector.add(actualX2, actualY2, diffX, diffY)
  end
  self:setPositionWithBumpCoords(actualX, actualY)
  local newX,newY = self:getPosition()
  return vector.sub(oldX, oldY, newX, newY)
end


function MapEntity:moveWithRoomEdgeCollisionBox(dt)

end

-- combat component pass throughs

function MapEntity:isIntangible()
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

function MapEntity:getKnockbackVelocity(dt)
  return self.combat:getKnockbackVelocity(dt)
end

--- hurt this entity
---@param damageInfo DamageInfo|integer
function MapEntity:hurt(damageInfo)
  if type(damageInfo) == 'number' then
    local damage = damageInfo
    damageInfo = DamageInfo()
    damageInfo.damage = damage
  end
  self:resetCombatVariables()
  if damageInfo:applyHitstun() then
    self:setHitstun(damageInfo.hitstunTime)
    self:setIntangibility(damageInfo.hitstunTime)
    self:flashSprite(damageInfo.hitstunTime)
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
  self:signal('entityHit')
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
  self:signal('entityBumped')
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
function MapEntity:updateEntityEffectSprite(dt)
  if self.shadowVisible and self:isInAir() then
    if self.effectSprite:getCurrentAnimationKey() ~= 'shadow' or not self.effectSprite:isVisible() then
      self.effectSprite:play('shadow')
      self.effectSprite:setVisible(true)
      self.effectSprite.alpha = .5
    end
  elseif self.effectSprite:isVisible() then
    self.effectSprite:stop()
    self.effectSprite:setVisible(false)
  end
  self.effectSprite:update(dt)
end

-- signal callbacks
function MapEntity:_onHealthDepleted()
  self.deathMarked = true
end

return MapEntity
