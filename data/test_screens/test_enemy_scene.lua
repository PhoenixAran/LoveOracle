local Class = require 'lib.class'
local BaseScreen = require 'engine.screens.base_screen'
local tick = require 'lib.tick'
local TestEnemy = require 'data.entities.enemies.test_enemy'
local TestEnemyScene = Class { __includes = BaseScreen,
  init = function(self)
    self.testEnemy = nil
  end
}

function TestEnemyScene:enter(prev, ...)
  self.testEnemy = TestEnemy {
    name = 'testenemy',
    x = 24,
    y = 24
  }
  self.testEnemy:initTransform()
end

function TestEnemyScene:update(dt)
  self.testEnemy:update(dt)
end

function TestEnemyScene:draw()
  self.testEnemy:draw()
end