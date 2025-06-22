local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local BasicEnemy = require 'engine.entities.enemy.basic_enemy'
local CollisionTag = require 'engine.enums.collision_tag'
local Interactions = require 'engine.entities.interactions'
local EffectFactory = require 'engine.entities.effect_factory'
local Collider = require 'engine.components.collider'
local SpriteBank = require 'engine.banks.sprite_bank'

-- TODO color variants

local Stalfos = Class { __includes = BasicEnemy,
  init = function(self, args)
    if args == nil then
      args = { }
    end
    args.w, args.h = 10, 10
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
    args.useBumpCoords = false
    args.roomEdgeCollisionBox:setCollidesWithLayer('room_edge')
    args.fallInHoleEffectColor = 'orange'
  end
}

return Stalfos