local Class = require 'lib.class'
local rs = require 'lib.resolution_solution'


local oldX, oldY, oldW, oldH = 0,0,0,0

---@type love.Canvas
local gameCanvas

--- module that handles graphics scaling and shader application
--- wraps resolution solution
---@class DisplayHandler
local DisplayHandler = {
  
}

function DisplayHandler.init(args)
  if gameCanvas then
    gameCanvas:release()
  end
  gameCanvas = love.graphics.newCanvas(args.canvasWidth, args.canvasHeight)
  gameCanvas:setFilter('nearest', 'nearest')
  
  love.window.setMode(args.canvasWidth, args.canvasHeight, { resizable = true, vsync = true, minwidth = args.game_width, minheight = args.game_height })
  rs.conf(args)
end


function DisplayHandler.push()
  rs.push()

  oldX, oldY, oldW, oldH = love.graphics.getScissor()
  love.graphics.setScissor(rs.get_game_zone())
end

function DisplayHandler.pop()
  rs.pop()
  love.graphics.setScissor(oldX, oldY, oldW, oldH)
end


function DisplayHandler.debugInfo()
  rs.debug_info(0, 0)
end

-- love callback
function DisplayHandler.resize(w, h)
  rs.resize()
end

return DisplayHandler
