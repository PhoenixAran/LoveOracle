local monocle = {mouse = {}}

function monocle.setup(virtualWidth, virtualHeight, windowWidth, windowHeight)
  love.window.setMode(windowWidth, windowHeight)
  monocle.windowWidth = windowWidth
  monocle.windowHeight = windowHeight
  monocle.virtualWidth = virtualWidth
  monocle.virtualHeight = virtualHeight
  monocle.updateView()
end

function monocle.updateView()
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  
  if screenWidth / monocle.virtualWidth > screenHeight / monocle.virtualHeight then
    monocle.viewWidth = math.floor(screenWidth / monocle.virtualWidth * monocle.virtualHeight)
    monocle.viewHeight = math.floor(screenHeight)
  else
    monocle.viewWidth = math.floor(screenWidth)
    monocle.viewHeight = math.floor(screenWidth / monocle.virtualWidth * monocle.virtualHeight)
  end
  
  monocle.scaleX = math.floor(screenWidth / monocle.virtualWidth)
  monocle.scaleY = math.floor(screenHeight / monocle.virtualHeight)
  
  if monocle.canvas ~= nil then
    monocle.canvas:release()
  end
  
  monocle.canvas = love.graphics.newCanvas(monocle.viewWidth, monocle.viewHeight)
  monocle.canvas:setFilter("nearest", "nearest") 
end

function monocle.begin()
  love.graphics.push()
  love.graphics.scale(monocle.scaleX, monocle.scaleY)
  love.graphics.setCanvas(monocle.canvas)
  love.graphics.clear(100 / 255, 149 / 255, 237 / 255)
end

function monocle.finish()
  love.graphics.setCanvas()
  love.graphics.pop()
  love.graphics.draw(monocle.canvas, 0, 0)
end

return monocle