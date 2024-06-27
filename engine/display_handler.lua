local Class = require 'lib.class'
local rs = require 'lib.resolution_solution'


local oldX, oldY, oldW, oldH = 0,0,0,0

---@type love.Canvas
local gameCanvas



--- module that handles graphics scaling and shader application
--- wraps resolution solution
---@class DisplayHandler
local DisplayHandler = { }

function DisplayHandler.init(args)
  love.log.trace('DisplayHandler init')
---@diagnostic disable-next-line: duplicate-set-field
  rs.resize_callback = function()
    if gameCanvas then
      gameCanvas:release()
    end
    gameCanvas = love.graphics.newCanvas()
    gameCanvas:setFilter('nearest', 'nearest')
  end
  love.window.setMode(args.canvasWidth, args.canvasHeight, { resizable = true, vsync = true, minwidth = args.game_width, minheight = args.game_height })
  rs.conf(args)
end


function DisplayHandler.push()
  love.graphics.setCanvas(gameCanvas)
  love.graphics.clear(0, 0, 0, 1)

  rs.push()
  oldX, oldY, oldW, oldH = love.graphics.getScissor()
  love.graphics.setScissor(rs.get_game_zone())
end

function DisplayHandler.pop()
  love.graphics.setScissor(oldX, oldY, oldW, oldH)
  rs.pop()
  love.graphics.setCanvas()
  love.graphics.setBlendMode('alpha')
  love.graphics.draw(gameCanvas)
end

function DisplayHandler.getGameSize()
  return rs.get_game_size()
end

function DisplayHandler.debugInfo()
  rs.debug_info(0, 0)
end

-- love callback
function DisplayHandler.resize(w, h)
  rs.resize()
end

return DisplayHandler
