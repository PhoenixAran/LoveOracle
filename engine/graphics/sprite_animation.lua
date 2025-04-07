local Class = require 'lib.class'

local DEFAULT_KEY = 'default'

-- sprite animation instance
---@class SpriteAnimation
---@field spriteFrames SpriteFrame[]
---@field timedActions function[]
---@field substrips boolean if true, spriteFrames and timedActions are structured as a table of tables
---@field loopType string
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

---@param substripKey string|integer|nil
---@return SpriteFrame[]
function SpriteAnimation:getSpriteFrames(substripKey)
  if substripKey == nil then
    if self.substrips then
      return self.spriteFrames[DEFAULT_KEY]
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
      return self.timedActions[DEFAULT_KEY]
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
    for _, frames in pairs(self.spriteFrames) do
      for _, frame in pairs(frames) do
        frame:release()
      end
    end
  end
end

return SpriteAnimation