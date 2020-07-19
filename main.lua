local monocle = require 'lib.monocle'

-- globals >:)
assets = require('lib.cargo').init({
  dir = 'assets',
  processors = {
    ['images/'] = function(image, filename)
      image:setFilter('nearest', 'nearest')
    end
  }
})
screenManager = require('lib.roomy').new()
bumpWorld = require('lib.bump').newWorld(32)

local function drawFpsAndMemory()
  local fps = ("fps:%d, %d kbs"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(255, 255, 255)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

function love.load()
  love.window.setMode(160 * 4, 144 * 4, { resizable = true, vsync = true,  minwidth = 160, minheight = 144 })
  monocle.setup(160, 144, 160 * 4, 144 * 4)
  local font = assets.fonts.monogram(16)
  font:setFilter("nearest", "nearest")
  love.graphics.setFont(font)
  -- exclude draw and resize callback since we need to use maid64 scaling
  screenManager:hook({ exclude = {'draw',}})
  screenManager:enter( require 'game.test_screens.entity_test' ())
end

function love.draw()
  monocle.begin()
  -- manually call draw in current screen
  screenManager:emit('draw')
  drawFpsAndMemory()
  monocle.finish()
end

--function love.resize(w, h)
--  maid64.resize(w, h)
--  screenManager:emit('resize', w, h)
--end