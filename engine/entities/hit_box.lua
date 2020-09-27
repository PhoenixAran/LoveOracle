local Class = require 'lib.class'
local BumpBox = require 'engine.entities.bump_box'
local Component = require 'entine.entities.component'

local HitBox = Class { __includes = { BumpBox, Component },
  init = function(self)
    Component.init(self)
  end
}

return HitBox