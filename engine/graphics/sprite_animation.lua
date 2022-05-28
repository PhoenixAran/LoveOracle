local Class = require 'lib.class'

-- sprite animation instance
---@class SpriteAnimation
---@field spriteFrames table
---@field timedActions table
---@field substrips boolean
local SpriteAnimation = Class {
  init = function(self, spriteFrames, timedActions, loopType, substrips)
    if substrips == nil then substrips = false end
    assert(loopType == 'once' or loopType == 'cycle', 'Invalid loop type:' .. loopType)
    self.spriteFrames = spriteFrames
    self.timedActions = timedActions
    self.loopType = loopType
    self.substrips = substrips
    --[[
      if self.substrips is false, spriteFrames and timedActions will just be a flat table
      if self.substrips is true, spriteFrames will be structured as
      {
        1 = { ... } -- default when no substripKey is used in getter function
        up = { ... },
        down = { ... },
        left = { ... },
        right = { ... }
      }
      timedActions will also be structured as 
      {
        1 = { ... } -- default when no substripKey is used in getter function
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
  end
}

function SpriteAnimation:getType()
  return 'sprite_animation'
end

function SpriteAnimation:getSpriteFrames(substripKey)
  if substripKey == nil then
    if self.substrips then
      return self.spriteFrames[1]
    end
    return self.spriteFrames
  else
    if not self.substrips then
      return self.spriteFrames
    end
    return self.spriteFrames[substripKey]
  end
end

function SpriteAnimation:getTimedActions(substripKey)
  if substripKey == nil then
    if self.substrips then
      return self.timedActions[1]
    end
    return self.timedActions
  else
    if not self.substrips then
      return self.timedActions
    end
    return self.timedActions[substripKey]
  end
end

function SpriteAnimation:hasSubstrips()
  return self.substrips
end

function SpriteAnimation:release()
  self.timedActions = nil
  if self.substrips then
    for i, frames in pairs(self.spriteFrames) do
      for j, frame in pairs(frames) do
        frame:release()
      end
    end
  end
end

return SpriteAnimation