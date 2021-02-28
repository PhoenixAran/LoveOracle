local Monocle = { 
  mouse = { }
}

function Monocle.setup(monocle, monocleConfig, windowConfig)
  if monocleConfig == nil then
    monocleConfig = {
      windowWidth = 160,
      windowHeight = 144,
      virtualWidth = 160 * 4,
      virtualHeight = 144 * 4,
      maxScale = 10000
    }
  end
  if windowConfig == nil then
    windowConfig = {
      minwidth = 160,
      minheight = 144,
      vsync = true,
      resizable = true
    }
  end
  love.window.setMode(monocleConfig.virtualWidth, monocleConfig.virtualHeight, windowConfig)  
  monocle.virtualWidth = monocleConfig.virtualWidth
  monocle.virtualHeight = monocleConfig.virtualHeight
  monocle.windowWidth = monocleConfig.windowWidth
  monocle.windowHeight = monocleConfig.windowHeight
  monocle.maxScale = monocleConfig.maxScale
  monocle.updateView(monocle)
end

function Monocle.updateView(monocle)
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local scaleX = math.floor(screenWidth / monocle.windowWidth)
  local scaleY = math.floor(screenHeight / monocle.windowHeight)
  
  if scaleX ~= scaleY then
    if scaleX > scaleY then
      monocle.scale = scaleY
    else
      monocle.scale = scaleX
    end
  else
    monocle.scale = scaleX
  end
  if monocle.scale > monocle.maxScale then
    monocle.scale = monocle.maxScale
  end
  local viewWidth = monocle.windowWidth * monocle.scale
  local viewHeight = monocle.windowHeight * monocle.scale
  
  monocle.x = math.floor(screenWidth / 2 - viewWidth / 2)
  monocle.y = math.floor(screenHeight / 2 - viewHeight / 2)
  
  if monocle.canvas ~= nil then
    monocle.canvas:release()
  end
  monocle.canvas = love.graphics.newCanvas(viewWidth, viewHeight)
  monocle.canvas:setFilter('nearest', 'nearest') 
end

function Monocle.begin(monocle)
  love.graphics.push()
  love.graphics.scale(monocle.scale, monocle.scale)
  love.graphics.setCanvas(monocle.canvas)
  love.graphics.clear(.4, .4, .4, 1.0)
end

function Monocle.finish(monocle)
  love.graphics.setCanvas()
  love.graphics.pop()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(monocle.canvas, monocle.x, monocle.y)
  love.graphics.setBlendMode('alpha')
end

function Monocle.resize(monocle, w, h)
  monocle.updateView(monocle)
end

function Monocle.release(monocle)
  if monocle.canvas ~= nil then
    monocle.canvas:release()
  end
end

Monocle.__index = Monocle
function Monocle.new()
  local self = setmetatable({}, Monocle)
  return self
end

return Monocle