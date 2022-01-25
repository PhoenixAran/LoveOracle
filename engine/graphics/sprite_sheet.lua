local Class = require 'lib.class'
local lume = require 'lib.lume'
local Subtexture = require 'engine.graphics.subtexture'

local SpriteSheet = Class {
  init = function(self, image, width, height, margin, spacing)
    self.textures = { }
    if spacing == nil then
      spacing = 1
    end
    if margin == nil then
      margin = 1
    end
    local countedCols = false
    local rowCount, colCount = 0,0
    for y = margin, image:getHeight() - margin, height + spacing do
      for x = margin, image:getWidth() - margin, width + spacing do
        lume.push(self.textures, Subtexture(image, love.graphics.newQuad(x, y, width, height, image:getWidth(), image:getHeight())))
        if not countedCols then
          colCount = colCount + 1
        end
      end
      countedCols = true
      rowCount = rowCount + 1
    end
    self.rowCount = rowCount
    self.colCount = colCount
  end
}

function SpriteSheet:getType()
  return 'sprite_sheet'
end

function SpriteSheet:getTexture(x, y)
  if y == nil then -- treat x as a one dimensional index
    return self.textures[x]
  end
  return self.textures[(y - 1) * self.colCount + x]
end

function SpriteSheet:size()
  return lume.count(self.textures)
end

function SpriteSheet:release()
  for _, subtexture in ipairs(self.textures) do
    subtexture:release()
  end
end

return SpriteSheet