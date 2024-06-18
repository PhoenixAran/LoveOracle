local Class = require 'lib.class'
local Entity = require 'engine.entities.entity'
local lume = require 'lib.lume'
local vector = require 'math.vector'
local parse = require 'engine.utils.parse_helpers'

local PlatformPathCommandType = {
  Move = 'move',
  Pause = 'pause'
}

local LoopType = {
  Cycle = 0,
  PingPong = 1
}

---@class PlatformPathCommand
---@field commandType integer
---@field moveX integer tile indexes to move by vertically
---@field moveY integer tile indexes to move by vertically
---@field pauseTime integer amount of ticks this platform should stay still for
local PlatformPathCommand = Class {
  init = function(self, args)
    self.commandType = args.commandType
    self.moveX = args.moveX
    self.moveY = args.moveY
    self.pauseTime = args.pauseTime
  end
}

local function parsePathScript(script)

end

function PlatformPathCommand:getType()
  return 'platform_path_command'
end

---@class MovingPlatform : Entity
local MovingPlatform = Class { __includes = Entity,
  init = function(self, args)
  end
}

function MovingPlatform:getType()
  return 'moving_platform'
end


return MovingPlatform