local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'engine.entities.component'

-- maybe not be a bumpbox and implement some linecast / pointcast
-- in the global physics object
local GroundObserver = Class { __includes = {Component},
  init = function(self, entity, args)
    Component.init(self, entity, args)
    self.inLava = false
    self.inGrass = false
    self.onStairs = false
    self.onIce = false
    self.inWater = false
  end
}

function GroundObserver:getType()
  return 'ground_observer'
end

function GroundObserver:update(dt)
end

return GroundObserver