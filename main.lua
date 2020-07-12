local maid64 = require "lib.maid64"
local testPlayer

function love.load()
    love.window.setMode(160 * 4, 144 * 4, { resizable = true, vsync = true,  minwidth = 160, minheight = 144 })
    
    maid64.setup(160, 144)
    
    
    testPlayer = require('game.test_player')()
end

function love.update(dt)
    testPlayer:update(dt)
end

function love.draw()
    maid64.start()
    testPlayer:draw()
    maid64.finish()
end

function love.resize(w, h)
    -- this is used to resize the screen correctly
    maid64.resize(w, h)
end