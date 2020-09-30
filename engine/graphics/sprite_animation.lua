local Class = require 'lib.class'

-- should this really be a class? it kinda just serves at documentation at this point
local SpriteAnimation = Class {
  init = function(self, spriteFrames, timedActions, loopType)
    self.spriteFrames = spriteFrames
    self.timedActions = timedActions
    self.loopType = loopType
  end
}