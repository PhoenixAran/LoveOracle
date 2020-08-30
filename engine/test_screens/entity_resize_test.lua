local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local vector = require 'lib.vector'
local rect = require 'engine.utils.rectangle'
local TestEntity = require 'engine.test_game_entity'

local TestBox = Class { __includes = Entity,
  init = function(self, rect)
    Entity.init(self, true, true, rect)
    self:setPhysicsLayer('1')
  end
}

function TestBox:entityAwake()
  physics.add(self)
end

-- experiental physics test screen
local Screen = Class {
  init = function(self)
    self.testEntity = nil
    self.testBoxes = { }
  end
}

function Screen:enter(prev, ...)
  physics.reset()
  self.testEntity = TestEntity()
  self.testEntity:setCollidesWithLayer('1')
  self.testEntity:setPositionWithBumpCoords(3, 4)
  self.testEntity:awake()
  self.testBoxes[#self.testBoxes+ 1] = TestBox({x = 24, y = 24, w = 24, h = 24})
  self.testBoxes[#self.testBoxes]:entityAwake()
end

function Screen:update(dt)
  if love.keyboard.isDown('i') then
    self.testEntity:resize(32, 32)
  end  
  if love.keyboard.isDown('k') then
    self.testEntity:resize(32, 32)
  end
  if love.keyboard.isDown('j') then
    self.testEntity:resize(32, 16)
  end
  if love.keyboard.isDown('l') then
    self.testEntity:resize(16, 32)
  end
  if love.keyboard.isDown('n') then
    self.testEntity:resize(16, 16)
  end
  
  for _, b in ipairs(self.testBoxes) do
    b:update(dt)
  end
  self.testEntity:update(dt)
end

function Screen:draw()
  for _, b in ipairs(self.testBoxes) do
    b:draw()
    b:debugDraw()
  end
  self.testEntity:draw()
  self.testEntity:debugDraw()
end

return Screen