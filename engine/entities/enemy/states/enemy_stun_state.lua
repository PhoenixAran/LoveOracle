local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local EnemyState = require 'engine.entities.enemy.states.enemy_state'

-- TODO shake duration???
---@class EnemyStunState : EnemyState
local EnemyStunState = Class { __includes = EnemyState,
  init = function(self, args)
    EnemyState.init(self, args)
    self.timer = 0
  end
}

function EnemyStunState:getType()
  return 'enemy_stun_state'
end

function EnemyStunState:beginState()
  self.enemy:setVector(0, 0)
  self.timer = 0
  if self.enemy.sprite then
    self.enemy.sprite:pause()
  end
end


function EnemyStunState:endState()
  if self.enemy.sprite then
    self.enemy.sprite:play()
  end
end

function EnemyStunState:update()
  self.timer = self.timer + 1
  local ex, ey = self.enemy:getPosition()
  if self.timer % 8 == 0 then
    self.enemy:setPosition(ex + 1, ey + 1)
  elseif self.timer % 8 == 4 then
    self.enemy:setPosition(ex - 1, ey - 1)
  end
  if not self.enemy:inHitstun() then
    self.enemy:beginNormalState()
  end
end

function EnemyStunState:free()
  EnemyState.free(self)
  self.timer = 0
end

return EnemyStunState