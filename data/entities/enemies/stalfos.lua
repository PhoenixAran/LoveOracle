local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local Enemy = require 'engine.entities.enemy'
local Direction4 = require 'engine.enums.direction4'
local SpriteBank = require 'engine.banks.sprite_bank'
local Collider = require 'engine.components.collider'
local Hitbox = require 'engine.components.hitbox'


local MOVING = 1
local HURT = 2
local JUMP = 3
local MARKED_DEAD = 4

local Stalfos = Class { __includes = Enemy,
  init = function(self, args)
    if args == nil then
      args = { }
    end
    args.w, args.h = 8, 9
    args.direction = args.direction or Direction4.down
    Enemy.init(self, args)
    self.sprite = SpriteBank.build('stalfos', self)
    self.spriteFlasher:addSprite(self.sprite)
    self.roomEdgeCollisionBox = Collider(self, {
      x = -12 / 2,
      y = -13 / 2,
      w = 12,
      h = 16,
      offsetX = 0,
      offsetY = 0,
      detectOnly = true
    })
    self.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')
    self:setCollidesWithLayer('tile')
    self:setCollisionTile({'wall'})
    self.state = MOVING
  end
}

function Stalfos:getType()
  return 'stalfos'
end

function Stalfos:chooseDirection()

end

function Stalfos:prepForMoveState()
  self:resetCombatVariables()
  self:setVector(0, 0)
  self:chooseDirection()
end



return Stalfos

