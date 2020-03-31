local push = require 'lib.push'
local baton = require 'lib.baton'

--globals
Input = baton.new {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'},
    action = {'key:x', 'button:a'},
  },
  pairs = {
    move = {'left', 'right', 'up', 'down'}
  },
  joystick = love.joystick.getJoysticks()[1],
}

--resolution stuff
love.graphics.setDefaultFilter('nearest', 'nearest')
local gameWidth, gameHeight = 160, 144
local windowWidth, windowHeight = 160 * 5, 144 * 5

love.window.setMode(windowWidth, windowHeight)

local scene = require('game.test_scenes.entity_with_hitbox_test')()
function love.load()
  love.graphics.setFont(love.graphics.newFont("monogram.ttf", 16))
  scene:load()
end

function love.update(delta)
  Input:update(delta)
  scene:update(delta)
end

function love.draw()
  love.graphics.scale(4, 4)
  scene:draw()
  local fps = ("fps:%d, %d kbs"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(fps, 0, 132, 60, 'left')
end
