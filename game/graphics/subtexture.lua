local Class = require 'lib.class'

local Subtexture = class {
  init = function(self, image, quad)
    self.image = image
    self.quad = quad
  end
}

function Subtexture:getType()
  return 'subtexture'
end

function Subtexture:getDimensions()
  local _, _, w, h = self.quad:getViewport()
  return w, h
end

return Subtexture