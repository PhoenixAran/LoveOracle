local class = require 'lib.class'
local bump = require 'lib.bump'
local quadHelper = require 'lib.quadHelper'
local Vector2 = require 'lib.vec2'
local Scene = require 'engine.scene'
local Sprite = require 'engine.graphics.sprite'
local Entity = require 'engine.entities.entity'

local EntityWithSpriteTest = class {
  __includes = Scene,
  init = function(self)
    self.entity = nil
    self.world = nil
  end
}

function buildEntity()
  local sb = require('engine.graphics.sprite_builder')()
  local entity = Entity(0, 0, 8, 9)
  local sprite = Sprite(love.graphics.newImage('player.png'), 16, 16)
  sprite:setLocalPosition(0, -3)
  sb:setSprite(sprite)
  sb:setQuadCollection(quadHelper.generateQuad(sprite.image, 16, 16, 1), 7, 29)

  --build walking
  sb:setQuad(0, 6)
    :setDelay(6)
    :buildFrame()
  sb:setQuad(0, 7)
    :setDelay(6)
    :buildFrame()
  sb:setLooptype("cycle")
  sb:buildAnimation("walking")

  entity:addComponent(sprite)
  sprite:play("walking")
  return entity
end

function EntityWithSpriteTest:load()
  self.world = bump.newWorld(32)
  self.entity = buildEntity()
  self.entity:setBumpWorld(self.world)
  self.entity:awake()
end

function EntityWithSpriteTest:update(dt)
  self.entity:update(dt)
  local xInput, yInput = 0, 0
  if Input:down('up') then
    yInput = -1
  elseif Input:down('down') then
    yInput = 1
  end

  if Input:down('left') then
    xInput = -1
  elseif Input:down('right') then
    xInput = 1
  end

  self.entity:setVector(xInput, yInput)
  self.entity:move(self.entity:getLinearVelocity(dt))
end

function EntityWithSpriteTest:draw()
  self.entity:draw()
  self.entity:debugDraw()
end

return EntityWithSpriteTest
