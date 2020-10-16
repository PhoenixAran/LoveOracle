local Monocle = { 
  mouse = { }
}
Monocle.__index = Monocle


function Monocle.new()
  local self = setmetatable({}, Monocle)
  return self
end

function Monocle.setup(monocle, virtualWidth, virtualHeight, windowWidth, windowHeight, windowConfig)
  if windowConfig == nil then
    love.window.setMode(windowWidth, windowHeight)
  else
    love.window.setMode(windowWidth, windowHeight, windowConfig)
  end
  monocle.virtualWidth = virtualWidth
  monocle.virtualHeight = virtualHeight
  monocle.updateView(monocle)
end

function Monocle.updateView(monocle)
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local scaleX = math.floor(screenWidth / monocle.virtualWidth)
  local scaleY = math.floor(screenHeight / monocle.virtualHeight)
  
  if scaleX ~= scaleY then
    if scaleX > scaleY then
      monocle.scale = scaleY
    else
      monocle.scale = scaleX
    end
  else
    monocle.scale = scaleX
  end
  
  local viewWidth = monocle.virtualWidth * monocle.scale
  local viewHeight = monocle.virtualHeight * monocle.scale
  
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
  love.graphics.clear(111 / 255, 203 / 255, 171 / 255)
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

return Monocle