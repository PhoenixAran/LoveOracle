local monocle = require 'lib.monocle'

local function drawFpsAndMemory()  
  local fps = ("fps:%d, %d kbs"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

function love.load()
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
  camera = require('lib.camera')(0,0,160, 144)
  input = require('lib.baton').new(require('controls'))

  monocle.setup(160, 144, 160 * 4, 144 * 4)
  
  local font = assets.fonts.monogram(16)
  font:setFilter("nearest", "nearest")
  love.graphics.setFont(font)
  
  screenManager:hook({ exclude = {'update','draw', 'resize'}})
  screenManager:enter( require 'game.test_screens.composite_sprite_test' ())
end

function love.update(dt)
  input:update(dt)
  screenManager:emit('update', dt)
end

function love.draw()
  monocle.begin()
  -- manually call draw in current screen
  screenManager:emit('draw')
  --drawFpsAndMemory()
  monocle.finish()
end

function love.resize(w, h)
  monocle.resize(w, h)
  screenManager:emit('resize', w, h)
end