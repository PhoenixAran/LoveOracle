local Class = require 'lib.class'
local lume = require 'lib.lume'
local inspect = require 'lib.inspect'

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

---@class Palette
---@field name string
---@field originalColors number[]
---@field alternateColors number[]
---@field shader love.Shader
---@field normalizeValues boolean
local Palette = Class {
  init = function(self, name, originalColors, alternateColors)
    self.name = name
    -- color tables will be array of tables 
    -- table elements will represent colors as such: { .23, .1, .32 } (alpha values not supported!)
    self.originalColors = originalColors or { }
    self.alternateColors = alternateColors or { }
    self.shader = nil
    self.normalizeValues = true
  end
}

function Palette:getName()
  return self.name
end

---adds color pair for shader
---@param originalColor number[]
---@param alternateColor number[]
function Palette:addColorPair(originalColor, alternateColor)
  assert(lume.count(originalColor) == 3, 'color must be an array of 3 values')
  assert(lume.count(alternateColor) == 3, 'alternateColor must be an array of 3 values')
  -- clone because you never know if the table is stored as a local variable or something
  -- normalizing values and appending the alpha value will cause the asserts above to fail
  -- if table is used again
  originalColor = lume.clone(originalColor)
  alternateColor = lume.clone(alternateColor)
  if self.normalizeValues then
    for k, v in ipairs(originalColor) do
      originalColor[k] = originalColor[k] / 255
    end
    for k, v in ipairs(alternateColor) do
      alternateColor[k] = alternateColor[k] / 255
    end
  end  
  --lets automatically provide an alpha value
  lume.push(originalColor, 1)
  lume.push(alternateColor, 1)
  -- add colors to color array
  lume.push(self.originalColors, originalColor)
  lume.push(self.alternateColors, alternateColor)
end

---returns the love shader instance
---@return love.Shader
function Palette:getShader()
  return self.shader
end

function Palette:compileShader()
  assert(not self.shader, 'Attempting to compile already compiled shader')
  self.shader = makePaletteShader(self.originalColors, self.alternateColors)
  if lume.count(self.originalColors) == 0 then return end
  if lume.count(self.originalColors) == 1 then
    self.shader:sendColor('originalColors', self.originalColors[1])
    self.shader:sendColor('alternateColors', self.alternateColors[1])
  else
    local otherOrignalColors = lume.slice(self.originalColors, 1)
    local otherAlternateColors = lume.slice(self.alternateColors, 1)
---@diagnostic disable-next-line: redundant-parameter
    self.shader:sendColor('originalColors', self.originalColors[1], otherOrignalColors)
---@diagnostic disable-next-line: redundant-parameter
    self.shader:sendColor('alternateColors', self.alternateColors[1], otherAlternateColors)
  end
end

function Palette:release()
  if self.shader then
    self.shader:release()
  end
end

return Palette