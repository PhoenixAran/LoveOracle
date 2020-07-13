local Class = require 'lib.class'

local Subtexture = class {
  init = function(self, image, quad)
    self.image = image
    self.quad = quad
  end
}

return Subtexture