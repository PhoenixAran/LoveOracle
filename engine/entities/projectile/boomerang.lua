local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Projectile = require 'engine.entities.projectile.projectile'
local EntityTracker = require 'engine.entities.entity_tracker'
local SimpleStateMachine = require 'engine.utils.simple_state_machine'
local Interactions = require 'engine.entities.interactions'
local CollisionTag = require 'engine.enums.collision_tag'
local EffectFactory = require 'engine.entities.effect_factory'
local Collider = require 'engine.components.collider'


local BoomerangState = {
  moving = 1,
  returning = 2
}

---@class Boomerang : Projectile
---@field returnDelay integer
---@field returnTimer integer
---@field returnToOwnerDistance number the distance from the owner at which the boomerang will be considered to have returned to the owner and trigger the onReturnedToOwner callback. Recommended value is speed * 1/tickrate
---@field stateMachine SimpleStateMachine
---@field boomerangTracker EntityTracker
local Boomerang = Class { __includes = Projectile,
  init = function(self, args)
    if args.width == nil and args.height == nil then
      args.width = 2
      args.height = 2
    end

    Projectile.init(self, args)

    self.roomEdgeCollisionBox = Collider(self, {
      x = -1,
      y = -1,
      w = 2,
      h = 2
    })

    self.hitbox:setCollisionTag(CollisionTag.thrownProjectile)

    self.boomerangTracker = EntityTracker()
    self.movement:setSpeed(90)
    self.returnDelay = 40
    self.returnTimer = 0
    self.returnToOwnerDistance = 1.5

    self.stateMachine = SimpleStateMachine(self, BoomerangState)
    self.stateMachine:addState(BoomerangState.moving, {
      onBegin = self.onBeginMovingState,
      onUpdate = self.onUpdateMovingState
    })
    self.stateMachine:addState(BoomerangState.returning, {
      onBegin = self.onBeginReturningState,
      onUpdate = self.onUpdateReturningState
    })
  end
}

function Boomerang:getType()
  return 'boomerang'
end

-- boomerang methods

function Boomerang:beginReturning()
  if self.stateMachine.currentState ~= BoomerangState.returning then
    self.stateMachine:beginState(BoomerangState.returning)
  end
end

function Boomerang:onReturnedToOwner()
  
end

-- state callbacks

function Boomerang:onBeginMovingState()
  self.returnTimer = 0
end

function Boomerang:onUpdateMovingState()
  self.returnTimer = self.returnTimer + 1
  if self.returnTimer > self.returnDelay then
    self.stateMachine:beginState(BoomerangState.returning)
  end
end

function Boomerang:onBeginReturningState()
  self:disableCollisions()
  self.roomEdgeCollisionBox:setEnabled(false)
end

function Boomerang:onUpdateReturningState()
  -- move towards owner
  local ownerX, ownerY = self.owner:getPosition()
  local directionToOwnerX, directionToOwnerY = vector.sub(ownerX, ownerY, self:getPosition())
  if vector.len(directionToOwnerX, directionToOwnerY) <= self.returnToOwnerDistance then
    self:onReturnedToOwner()
    self:destroy() 
  else
    self.movement:setVector(vector.normalize(directionToOwnerX, directionToOwnerY))
  end
end


-- overrides

function Boomerang:onAwake()
  Projectile.onAwake(self)
  self.stateMachine:initializeOnState(BoomerangState.moving)
  self.sprite:play('move')
end

function Boomerang:intercept()
  if self.stateMachine.currentState ~= BoomerangState.returning then
    self:beginReturning()
    return true
  end
  return false
end

function Boomerang:onCollideSolid(solid)
  if solid.isTile and solid:isTile() then
    print(love.inspect(solid))
    local effect = EffectFactory.createClingEffectLight(self.x, self.y, 'blue')
    self:emit('spawned_entity', effect)
  end
  self:beginReturning()
end

function Boomerang:isReturning()
  return self.stateMachine.currentState == BoomerangState.returning
end

function Boomerang:update()
  self.stateMachine:update()
  -- don't call Projectile update if destroyed, since Projectile update assumes the projectile is still active and will try to move and check collisions, which will result in error
  if not self.destroyed then
    Projectile.update(self)
  end
end

Boomerang.BoomerangState = BoomerangState

return Boomerang