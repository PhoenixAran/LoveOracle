local Class = require 'lib.class'
local lume = require 'lib.lume'

local function makePaletteShader(originalColors, alternateColors)
  assert(lume.count(originalColors) == lume.count(alternateColors), 'OriginalColors and AlternateColors array length need to match for palette shader')
  local count = lume.count(originalColors)
  -- credits to https://github.com/thomasgoldstein/zabuyaki
  local shaderCode = 'const int colorCount = ' .. tostring(count) .. ';'  -- ironic that this is const lol
  shaderCode = shaderCode .. [[
    uniform vec4 originalColors[colorCount];
    uniform vec4 alternateColors[colorCount];
    
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      // This is the current pixel color
      vec4 pixel = Texel(texture, texture_coords); 
      for (int i = 0; i < colorCount; ++i) {
        if (pixel == originalColors[i]) {
          // return alternate color if it matches an specified original color
          return alternateColors[i] * color;
        }
      }
      // return default color if it does not match any of the designated original colors
      return pixel * color;
    }
  ]]
  return love.graphics.newShader(shaderCode)
end

local Palette = Class {
  init = function(self, name, originalColors, alternateColors)
    self.name = name
    
    -- color tables will be array of tables 
    -- table elements will represent colors as such: { .23, .1, .32 } (alpha values not supported!)
    self.originalColors = originalColors or { }
    self.alternateColors = alternateColors or { }
    self.hash = nil
    self.shader = nil
  end
}

function Palette:getName()
  return self.name
end

function Palette:addColorPair(originalColor, alternateColor)
  --lets automatically provide an alpha value
  originalColor.a = 1
  alternateColor.a = 1
  lume.push(self.originalColors, originalColor)
  lume.push(self.alternateColors, alternateColor)
end

function Palette:getShader()
  return self.shader
end

function Palette:compileShader()
  assert(self.shader, 'Attempting to compile already compiled shader')
  self.shader = makePaletteShader(self.originalColors, self.alternateColors)
  self.shader:sendColor('originalColors', self.originalColors)
  self.shader:sendColor('alternateColors', self.alternateColors)
end

return Palette