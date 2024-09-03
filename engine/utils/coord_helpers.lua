---convert bottomleft coordinate to topleft
local function convertBottomLeftToTopLeft(x,y,w,h)
  if x == nil then
    return nil, nil
  end
  if w == nil then
    return x, y
  end
  return x, y - h
end

return {
  convertBottomLeftToTopLeft = convertBottomLeftToTopLeft
}