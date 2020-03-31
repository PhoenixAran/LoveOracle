local class = require 'lib.class'

local SpriteFrame = class {
  init = function(self, quad, delay, offsetX, offsetY, event)
    if offsetX == nil then
      offsetX = 0
    end
    if offsetY == nil then
      offsetY = 0
    end

    self.offsetX = offsetX
    self.offsetY = offsetY
    self.quad = quad
    self.event = event
    --by default, each sprite frame will display for 1 frame only
    self.delay = delay or 1
  end
}

function getType()
  return 'spriteframe'
end

function SpriteFrame:invokeEvent(args)
  if self.event ~= nil then
    self.event(args)
  end
end

return SpriteFrame
