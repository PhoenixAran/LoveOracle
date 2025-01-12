local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Enemy = require 'engine.entities.enemy'
local Direction4 = require 'engine.enums.direction4'
local SpriteBank = require 'engine.banks.sprite_bank'
local Collider = require 'engine.components.collider'
local Hitbox = require 'engine.components.hitbox'
local Direction8 = require 'engine.enums.direction8'


local MOVING = 1
local HURT = 2
local JUMP = 3
local MARKED_DEAD = 4

---@class Stalfos : Enemy
local Stalfos = Class { __includes = Enemy,
  init = function(self, args)
    if args == nil then
      args = { }
    end
    args.w, args.h = 8, 9
    args.direction = args.direction or Direction4.down
    args.sprite = SpriteBank.build('stalfos', self)
    args.roomEdgeCollisionBox = Collider(self, {
      x = -12 / 2,
      y = -13 / 2,
      w = 12,
      h = 16,
      offsetX = 0,
      offsetY = 0
    })
    args.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')

    Enemy.init(self, args)
    self:setCollidesWithLayer({'tile', 'ledge_jump'})
    self:setCollisionTile('wall')

    self.spriteFlasher:addSprite(self.sprite)
    self.movement:setSpeed(40)

    self.state = MOVING
    self.moveDirection4 = Direction4.down
    self.moveTimer = 0
    self.changeDirectionTimer = 0
    self.currentJumpDelay = 70
    self.currentDirectionDelay = 30
  end
}

function Stalfos:getType()
  return 'stalfos'
end

function Stalfos:prepForMoveState()
  self:resetCombatVariables()
  self:setVector(0, 0)
  self.moveDirection4 = self:getRandomDirection8()
  self.moveTimer = 0
  self.changeDirectionTimer = 0
  self.currentJumpDelay = math.floor(love.math.random(70, 121))
  self.currentDirectionDelay = math.floor(love.math.random(30, 71))
end


function Stalfos:land()
  self:prepForMoveState()
  self.state = MOVING
end

function Stalfos:update()
  self:updateEntityEffectSprite()
  self.spriteFlasher:update()
  self.sprite:update()
  self.combat:update()
  self.movement:update()

  if self.state == MOVING then
    self.moveTimer = self.moveTimer + 1
    self.changeDirectionTimer = self.changeDirectionTimer + 1
    if self.moveTimer > self.currentJumpDelay then
      self:jump()
    else
      local shouldChangeDirection = false
      shouldChangeDirection = self.currentDirectionDelay > self.currentDirectionDelay

      local x, y = Direction8.getVector(self.moveDirection4)
      x, y = vector.normalize(x, y)
      self:setVector(x, y)
      self:move()
      self.sprite:play('move')

      local collidedWithWall = false
      for _, collision in ipairs(self.moveCollisions) do
        if collision.isTile and collision:isTile() then
          if collision:isWall() then
            collidedWithWall = true
            break
          end
        end
      end
      
      shouldChangeDirection = shouldChangeDirection or collidedWithWall
      if shouldChangeDirection then
        self.moveDirection4 = self:getRandomDirection8()
        self.changeDirectionTimer = 0
        self.currentDirectionDelay = math.floor(love.math.random(70, 121))
      end
    end
  elseif self.state == JUMP then
    if self:isOnGround() then
      self:land()
    end
  elseif self.state == HURT then
    if not self.combat:inHitstun() then
      self:prepForMoveState()
      self.state = MOVING
    end
  elseif self.state == MARKED_DEAD then
    if not self.combat:inHitstun() then
      self:die()
    end
  end
end

-- callbacks
function Stalfos:onJump()
  self.state = JUMP
  self.sprite:play('jump')
end

function Stalfos:onHealthDepleted()
  self.state = MARKED_DEAD
end

return Stalfos

