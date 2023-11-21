local Class = require 'lib.class'
local rs = require 'lib.resolution_solution'


---@type love.Canvas
local mainCanvas

--- module that handles graphics scaling and shader application
--- wraps resolution solution
---@class DisplayHandler
local DisplayHandler = {
  
}

function DisplayHandler.init(options)
  if mainCanvas then
    mainCanvas:release()
  end
  rs.conf(options)

  mainCanvas = love.graphics.newCanvas(options.canvasWidth, options.canvasHeight)
  mainCanvas:setFilter('nearest', 'nearest')
end

function DisplayHandler.pop()
  rs.pop()
end

function DisplayHandler.push()
  rs.pop()
end

function DisplayHandler.resize(w, h)
  rs.resize()
end


return DisplayHandler
