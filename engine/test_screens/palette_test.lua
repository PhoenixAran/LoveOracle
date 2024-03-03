local Class = require 'lib.class'
local Slab = require 'lib.slab'
local inspect = require 'lib.inspect'
local assetManager = require 'engine.asset_manager'
local DisplayHandler = require 'engine.display_handler'

local PaletteTest = Class {
  init = function(self)
    self.testEntity = nil
  end
}


function PaletteTest:enter(prev, ...)
  self.spriteSheet = assetManager.getSpriteSheet('player')
  -- credits to https://github.com/thomasgoldstein/zabuyaki
  -- for figuring out this easy to use palette swap shader
  self.shader = love.graphics.newShader [[ 
    // Color Swap Shader
    const int colorCount = 1; // in the real thing, assingn this dynamically with lua string
    uniform vec4 originalColors[colorCount];
    uniform vec4 alternateColors[colorCount];         
    
    vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
      vec4 pixel = Texel(texture, texture_coords );//This is the current pixel color
      for (int i = 0; i < colorCount; i++) {
        if (pixel == originalColors[i]) {
          return alternateColors[i] * color;
        }
      }
      return pixel * color;
    }
  ]]
  self.color = { 148 / 255, 18 / 255, 172 / 255, 1 }
  self.shader:sendColor('originalColors', {16 / 255 , 168/ 255, 64 / 255, 1 })
  self.shader:sendColor('alternateColors', self.color )
end

function PaletteTest:update(dt)
  Slab.Update(dt)
  local result  = Slab.ColorPicker(self.color)
  if result.Color then
    self.color = result.Color
  end
  self:updateColor()
end

function PaletteTest:updateColor()
  self.shader:sendColor('alternateColors', self.color)
end

function PaletteTest:draw()
  DisplayHandler.push()
  local subtexture = self.spriteSheet:getTexture(1)
  love.graphics.setShader(self.shader)
  love.graphics.draw(subtexture.image, subtexture.quad, 160 / 2, 144 / 2)
  love.graphics.setShader()
  love.graphics.setColor(0, 70 / 255, 120 / 255, 255 / 255)
  love.graphics.rectangle("line", (160 / 2) - 1, (144 / 2) - 1, 18, 18)
  love.graphics.setColor(1, 1, 1)
  DisplayHandler.pop()
  Slab.Draw()
end

return PaletteTest