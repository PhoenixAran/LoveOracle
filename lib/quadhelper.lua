local quadHelper = { }


--this only works for the images generated with 1px padded grid and
--helper index images on the spritesheet
--see any spritesheet in this project to understand what this means
function quadHelper.generateQuad(image, cellWidth, cellHeight, cellPadding)
  local frames = { }
  if cellPadding == nil then
    cellPadding = 1
  end

  local xLimit = image:getPixelWidth() - cellWidth
  local yLimit = image:getPixelHeight() - cellHeight

  for j = 0, yLimit, cellHeight + cellPadding do
    for i = 0, xLimit, cellWidth + cellPadding do
      --The (x, y) are now at the rect with padding
      --Now we apply the padding value to get the rectangle without the padding
      --print('(' .. i .. ',' .. j .. ')')
      local xValue = i + 1
      local yValue = j + 1
      frames[#frames + 1] = love.graphics.newQuad(xValue, yValue, cellWidth, cellHeight, image:getDimensions())
    end
  end

  return frames
end

return quadHelper
