local Class = require 'lib.class'

---@class Subtexture
---@field image love.Image
---@field quad love.Quad
local Subtexture = Class {
  init = function(self, image, quad)
    self.image = image
    self.quad = quad
  end
}

function Subtexture:getType()
  return 'subtexture'
end

---returns dimensions of subtexture
---@return number w
---@return number h
function Subtexture:getDimensions()
  local _, _, w, h = self.quad:getViewport()
  return w, h
end

function Subtexture:release()
  if self.quad then
    self.quad:release()
  end
end

return Subtexture