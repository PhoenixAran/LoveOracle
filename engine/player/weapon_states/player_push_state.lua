local Class = require 'lib.class'
local PlayerState = require 'engine.player.player_state'
local Direction4 = require 'engine.enums.direction4'


local Mode = {
  RealPush = 1,
  FakePush = 2 
}

---@class PlayerPushState : PlayerState
---@field pushTimer integer 
---@field pushTile Tile|Entity|nil
---@field mode integer
---@field direction4 integer
local PlayerPushState = Class { __includes = PlayerState,
  init = function(self, player)
    PlayerState.init(self, player)
    self.stateParameters.animations.move = 'push'
    self.stateParameters.animations.idle = 'push'
    self.pushTimer = 0
    self.pushTile = nil
    self.mode = Mode.RealPush
    self.direction4 = -1
  end
}

function PlayerPushState:onBegin()
  self.direction4 = self.player:getDirection4()
  if self.pushTile:getType() == 'tile' then
    self.mode = Mode.FakePush
  elseif self.pushTile:getType() == 'push_block' then
    self.mode = Mode.RealPush
  end
end

function PlayerPushState:getType()
  return 'player_push_state'
end

function PlayerPushState:update(dt)
  local px, py = self.player:getVector()
  if px == 0 and py == 0 then
    self:endState()
    return
  end
  local currentDirection4 = self.player:getDirection4()
  local currentAnimationDirection4 = self.player:getAnimationDirection4()
  if currentDirection4 ~= currentAnimationDirection4 then
    self:endState()
    return
  end
  if currentDirection4 ~= self.direction4 then
    self:endState()
    return
  end

  -- do actualy logic on push stuff
  if self.mode == Mode.RealPush then
    error('not yet implemented')
    self.pushTimer = self.pushTimer + 1
  end
end

function PlayerPushState:onEnd(newState)
  self.pushTimer = 0
  self.pushTile = nil
  self.direction4 = -1
end 

return PlayerPushState