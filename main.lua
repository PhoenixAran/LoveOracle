local maid64 = require 'lib.maid64'

-- globals >:)
screenManager = require('lib.roomy').new()


function love.load()
  love.window.setMode(160 * 4, 144 * 4, { resizable = true, vsync = true,  minwidth = 160, minheight = 144 })
  maid64.setup(160, 144)
  -- exclude draw callback since we need to use maid64 scaling
  screenManager:hook({ exclude = {'draw'}})
  screenManager:enter( require 'game.test_screens.entity_test' )
end

function love.draw()
  maid64.start()  
  -- manually call draw in current screen
  screenManager:emit("draw")
  maid64.finish()
end

-- assign love.resize to the maid64 resize callback
love.resize = maid64.resize