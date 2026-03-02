local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'

--- Class that holds 9 subtextures that can be used to draw a 9 patch texture
--- @class NinePatchTexture
--- @field subtextures Subtexture set of the 9 subtextures that make up the 9-patch
local NinePatchTexture = Class {
  init = function(self, subtextures)
    -- Initialization code here
      assert(#subtextures == 9, "NinePatchTexture requires exactly 9 subtextures")
      self.subtextures = subtextures
  end
}

function NinePatchTexture:getSubtextures()
  return self.subtextures
end

function NinePatchTexture:getType()
  return 'nine_patch_texture'
end

return NinePatchTexture