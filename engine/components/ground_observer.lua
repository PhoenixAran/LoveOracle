local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'

local GroundObserver = Class { __includes = {BumpBox, Component},
  init = function(self)
    self.inLava = false
    -- not sure if i need this yet
    --self.inAir = false
    self.inGrass = false
    self.onStairs = false
    self.onIce = false
    self.inWater = false
  end
}

function GroundObserver:getType()
  return 'groundobserver'
end

return GroundObserver