function love.load()
  love.graphics.setFont(love.graphics.newFont("monogram.ttf", 16))
end

function love.draw()
  love.graphics.print("Hello", 50, 50)
end
