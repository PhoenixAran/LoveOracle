local Class = require 'lib.class'
local Component = require 'engine.entity.component'

local WanderDirectionType = {
  Random = 1,
  Random8 = 2,
  Random4 = 3,
}

local WanderOverlay = Class { __includes = Component,
  init = function(self, entity)
    self.entity = entity
  end
}

function WanderOverlay:getType()
  return 'wander_overlay'
end

function WanderOverlay:update()
  
end

function WanderOverlay:draw()

end

return WanderOverlay