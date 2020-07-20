local monocle = {mouse = {}}

function monocle.setup(virtualWidth, virtualHeight, windowWidth, windowHeight, viewPadding)
  if viewPadding == nil then viewPadding = 0 end
  love.window.setMode(windowWidth, windowHeight, {resizable = true, minwidth = virtualWidth, minheight = virtualHeight})
  monocle.virtualWidth = virtualWidth
  monocle.virtualHeight = virtualHeight
  monocle.viewPadding = viewPadding
  monocle.updateView()
end

function monocle.updateView()
  local screenWidth = love.graphics.getWidth()
  local screenHeight = love.graphics.getHeight()
  local prt = nil
  if screenWidth / monocle.virtualWidth > screenHeight / monocle.virtualHeight then
    monocle.viewWidth = math.floor(screenHeight / monocle.virtualHeight * monocle.virtualWidth)
    monocle.viewHeight = math.floor(screenHeight)
  else
    monocle.viewWidth = math.floor(screenWidth)
    monocle.viewHeight = math.floor(screenWidth / monocle.virtualWidth * monocle.virtualHeight)
  end
  
  local aspect = monocle.viewHeight / monocle.viewWidth
  monocle.viewWidth = monocle.viewWidth - monocle.viewPadding * 2
  monocle.viewHeight = monocle.viewHeight - math.floor(aspect * monocle.viewPadding * 2)
  
  monocle.scaleX = math.floor(screenWidth / monocle.virtualWidth)
  monocle.scaleY = math.floor(screenHeight / monocle.virtualHeight)
  
  if monocle.scaleX ~= monocle.scaleY then
    if monocle.scaleX > monocle.scaleY then
      monocle.scaleX = monocle.scaleY
    else
      monocle.scaleY = monocle.scaleX
    end
  end
  
  monocle.viewWidth = monocle.virtualWidth * monocle.scaleX
  monocle.viewHeight = monocle.virtualHeight * monocle.scaleY
  
  monocle.x = math.floor(screenWidth / 2 - monocle.viewWidth / 2)
  monocle.y = math.floor(screenHeight / 2 - monocle.viewHeight / 2)
  
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
  love.graphics.draw(monocle.canvas, monocle.x, monocle.y)
end

function monocle.resize(w, h)
  monocle.updateView()
end

return monocle