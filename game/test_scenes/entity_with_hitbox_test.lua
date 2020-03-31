local class = require 'lib.class'
local bump = require 'lib.bump'
local Vector2 = require 'lib.vec2'
local Scene = require 'engine.scene'
local Entity = require 'engine.entities.entity'
local Hitbox = require 'engine.entities.hitbox'

local EntityWithHitboxTest = class {
  __includes = Scene,
  init = function(self)
    self.entity = nil
    self.world = nil
    self.staticBoxes = { }
    self.entities = { }
  end
}

function EntityWithHitboxTest:addEntity(x, y)
  local entity = Entity(x, y, 16, 16)
  local hitbox = Hitbox(10, 10, self.world)
  hitbox:setLocalPosition(0, -1)
  entity:addComponent(hitbox)
  entity:setBumpWorld(self.world)
  self.entities[#self.entities + 1] = entity
end

function EntityWithHitboxTest:addStaticBox(x, y, w, h)
  local block = { x = x, y = y, w = w, h = h }
  self.staticBoxes[#self.staticBoxes + 1] = block
  function block:getType()
    return 'tile'
  end
  self.world:add(block, x, y, w, h)
end

function EntityWithHitboxTest:drawStaticBoxes()
  for _, box in ipairs(self.staticBoxes) do
    love.graphics.setColor(255 / 255, 0, 0, 70 / 255)
    love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
    love.graphics.setColor(255 / 255, 0, 0)
    love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
  end
end

function EntityWithHitboxTest:load()
  self.world = bump.newWorld(32)
  self:addStaticBox(30, 30, 16, 16)
  self:addStaticBox(50, 50, 30, 24)


  for i = 1, 20 do
    self:addEntity(math.random(0, 160), math.random(0, 144))
  end
  for _, entity in ipairs(self.entities) do
    entity:awake()
  end
end

function EntityWithHitboxTest:update(dt)
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

  for _, entity in ipairs(self.entities) do
    entity:setVector(xInput, yInput)
    entity:move(entity:getLinearVelocity(dt))
    entity:update(dt)
  end
end

function EntityWithHitboxTest:draw()
  for _, entity in ipairs(self.entities) do
    entity:debugDraw()
  end
  self:drawStaticBoxes()
end

return EntityWithHitboxTest
