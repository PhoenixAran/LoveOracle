local Class = require 'lib.class'
local Component = require 'lib.entity.component'

local AnimatedSpriteRenderer = Class { __includes = Component,
  init = function(self)
    Component.init(self)
  end
}

return AnimatedSpriteRenderer