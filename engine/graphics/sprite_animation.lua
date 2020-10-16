local Class = require 'lib.class'

-- should this really be a class? it kinda just serves at documentation at this point
local SpriteAnimation = Class {
  init = function(self, spriteFrames, timedActions, loopType)
    assert(loopType == 'once' or loopType == 'cycle', 'Invalid loop type:' .. loopType)
    self.spriteFrames = spriteFrames
    self.timedActions = timedActions
    self.loopType = loopType
    --[[
      if self.hasSubStrips is false, spriteFrames and timedActions will just be a flat table
      if self.hasSubStrips is true, spriteFrames will be structured as
      {
        up = { ... },
        down = { ... },
        left = { ... },
        right = { ... }
      }
      timedActions will also be structured as 
      {
        up = { 
          2 : func(),
          ...
        }
        down = {
          2 : func(),
          ...
        },
        left = {
          3 : func(),
          ...
        },
        right = {
          3 : func(),
          ...
        }
      }
      
      This makes life easier since when can declare animation like: { move, hurt, flying, squish }
      instead of { moveup, movedown, moveleft, moveright, hurtup, hurtdown, hurtleft, ... }.
      This reduces the amount of animation keys, which makes programming entities easier since we're not constantly contatenating 
      a direction to the animationkey
    --]]
    self.hasSubStrips = false 
  end
}

function SpriteAnimation:getType()
  return 'spriteanimation'
end

return SpriteAnimation