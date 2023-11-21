local Class = require 'lib.class'
local rs = require 'lib.resolution_solution'


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
  rs.conf(args)

  gameCanvas = love.graphics.newCanvas(args.canvasWidth, args.canvasHeight)
  gameCanvas:setFilter('nearest', 'nearest')
  
  love.window.setMode(args.game_width, args.game_height, { resizable = true, vsync = true, minwidth = args.game_width, minheight = args.game_height })
end

function DisplayHandler.pop()
  rs.pop()
  --love.graphics.setCanvas()
end

function DisplayHandler.push()
  --love.graphics.setCanvas(gameCanvas)
  rs.push()
end

function DisplayHandler.debugInfo()
  rs.debug_info(0, 0)
end

-- love callback
function DisplayHandler.resize(w, h)
  rs.resize()
end

return DisplayHandler
