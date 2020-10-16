local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'

-- maybe not be a bumpbox and implement some linecast / pointcast
-- in the global physics object
local GroundObserver = Class { __includes = {BumpBox, Component},
  init = function(self)
    self.inLava = false
    self.inGrass = false
    self.onStairs = false
    self.onIce = false
    self.inWater = false
  end
}

function GroundObserver:getType()
  return 'groundobserver'
end

function GroundObserver:update(dt)
  -- TODO check tile
  -- for now just pretend this works
end

return GroundObserver