local maid64 = require 'lib.maid64'

-- globals >:)
screenManager = require('lib.roomy').new()

function love.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  love.window.setMode(160 * 4, 144 * 4, { resizable = true, vsync = true,  minwidth = 160, minheight = 144 })
  maid64.setup(160, 144)
  -- exclude draw callback since we need to use maid64 scaling and resizing
  screenManager:hook({ exclude = {'draw', 'resize'}})
  screenManager:enter( require 'game.test_screens.entity_test' )

end

function love.draw()
  maid64.start()  
  -- manually call draw in current screen
  screenManager:emit('draw')
  love.graphics.setColor(1, 1, 1)
  maid64.finish()
end

function love.resize(w, h)
  maid64.resize(w, h)
  screenManager:emit('resize', w, h)
end