local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local vector = require 'engine.math.vector'
local rect = require 'engine.math.rectangle'
local TestEntity = require 'engine.test_screens.test_game_entity'
local BaseScreen = require 'engine.screens.base_screen'
local lume = require 'lib.lume'
local bit = require 'bit'
local Physics = require 'engine.physics'
local DisplayHandler = require 'engine.display_handler'


local TestBox = Class { __includes = Entity,
  init = function(self, name, rect, zRange)
    Entity.init(self, {name = name, x = rect.x, y = rect.y, w = rect.w, h = rect.h, zMin = zRange.min, zMax = zRange.max})
    self:setPhysicsLayer('entity')
  end
}

-- experiental physics test screen
local Screen = Class { __includes = BaseScreen,
  init = function(self)
    self.testEntity = nil
    self.testBoxes = { }
  end
}

function Screen:enter(prev, ...)
  self.testEntity = TestEntity()
  self.testEntity:initTransform()
  self.testEntity:setCollidesWithLayer('entity')
  self.testEntity:awake()
  
  -- set range to 0, 50 for test player
  self.testEntity:setZRange(0, 50)

  -- this test box will be in the same range as the player
  lume.push(self.testBoxes, TestBox( 'testbox1', {x = 24, y = 24, w = 24, h = 24}, {min = 20, max = 30}))

  -- this test box will be 'under' the player
  lume.push(self.testBoxes, TestBox('testbox2', {x = 65, y = 40, w = 16, h = 12}, {min = -30, max = -4}))

  -- this test box will be 'above' the player
  lume.push(self.testBoxes, TestBox('testbox3', {x = 60, y = 16, w = 24, h = 21}, {min = 51, max = 200}))
  
  lume.each(self.testBoxes, 'initTransform')
  lume.each(self.testBoxes, 'awake')
end

function Screen:update()
  local s = require 'engine.singletons'
  s.input:update()
  for _, b in ipairs(self.testBoxes) do
    b:update()
  end
  self.testEntity:update()
end

function Screen:draw()
  DisplayHandler.push()
  for _, b in ipairs(self.testBoxes) do
    b:debugDraw()
  end
  self.testEntity:debugDraw()
  self:drawMemory()
  DisplayHandler.pop()
end

return Screen