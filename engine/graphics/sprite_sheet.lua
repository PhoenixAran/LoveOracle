local Class = require 'lib.class'
local Subtexture = require 'engine.graphics.subtexture'

local SpriteSheet = Class {
  init = function(self, image, width, height, padding, margin)
    self.textures = { }
    if padding == nil then padding = 1 end
    if margin == nil then margin = 0 end
    local countedCols = false
    local rowCount, colCount = 0, 0
    
    for y = margin, image:getHeight() - margin, height + padding do
      for x = margin, image:getWidth() - margin, width + padding do
        local subtexture = Subtexture(image, love.graphics.newQuad(x, y, width, height, image:getWidth(), image:getHeight()))
        self.textures[#self.textures + 1] = subtexture
        if not countedCols then colCount = colCount + 1 end
      end
      countedCols = true
      rowCount = rowCount + 1
    end
    
    self.rowCount = rowCount
    self.colCount = colCount
  end
}

function SpriteSheet:getTexture(x, y)
  if y == nil then -- treat x as a one dimensional index
    return self.textures[x]
  end 
  return self.textures[(x - 1) * self.colCount + y]
end

function SpriteSheet:size()
  return #self.textures
end

return SpriteSheet