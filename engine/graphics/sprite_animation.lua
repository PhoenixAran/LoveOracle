local class = require 'lib.class'

local SpriteAnimation = class{
  init = function(self, frames, loopType)
    if loopType == nil then
      loopType = "none"
    end

    self.frames = frames
    self.loopType = loopType
    self.currentIndex = 1
    self.currentTime = 0
    self.playing = false
  end
}

function SpriteAnimation:getType()
  return 'spriteanimation'
end

function SpriteAnimation:play(frame)
  self.playing = true
  if frame == nil then
    frame = 1
  end
  self.currentIndex = frame
  self.currentTime = 0
  self.frames[self.currentIndex]:invokeEvent()
end

function SpriteAnimation:update(dt, args)
  if not self.playing then
    return
  end

  local currentFrame = self.frames[self.currentIndex]
  self.currentTime = self.currentTime + 1
  if currentFrame.delay <= self.currentTime then
    self.currentTime = 0
    self.currentIndex = self.currentIndex + 1
    if self.currentIndex > #self.frames then
      if self.loopType == "none" then
        self.playing = false
        self.currentIndex = self.currentIndex - 1
      elseif self.loopType == "cycle" then
        self.currentIndex = 1
      end
    end
    currentFrame = self.frames[self.currentIndex]
    currentFrame:invokeEvent(args)
  end
end

function SpriteAnimation:getCurrentSpriteFrame()
  return self.frames[self.currentIndex]
end

return SpriteAnimation
