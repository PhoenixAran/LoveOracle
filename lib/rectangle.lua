-- methods for rectangle collisions
local rectMethods = { }

function rectMethods.union(rect1, rect2)
  local result = { }
  
  local resultX = math.min(rect1.x, rect2.x)
  local resultY = math.min(rect1.y, rect2.y)
  local resultW = math.max(rect1.x + rect1.w, rect2.x + rect2.w)
  local resultH = math.max(rect1.y + rect1.h, rect2.y + rect2.h)
  
  result.x = resultX
  result.y = resultY
  result.W = resultW
  result.H = resultH
end

function rectMethods.intersects(rect1, rect2)
  --return x1 < x2 + w2 and x2 < x1 + w1 and
  --       y1 < y2 + h2 and y2 < y1 + h1
  return rect1.x < rect2.x + rect2.w and rect2.x < rect1.x + rect1.w and
         rect1.y < rect2.y + rect2.y and rect2.y < rect1.y + rect1.h
end

function rectMethods.containsPoint(rect, px, py)
  return rect.x <= px and px < rect.x + rect.w and
         rect.y <= py and py < rect.y + rect.h
end

return rectMethods