local Class = require 'lib.class'
local GameEntity = require 'engine.entities.game_entity'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'

local Player = Class { __includes = GameEntity,
  init = function(self, enabled, visible, rect) 
    GameEntity.init(self, enabled, visible, rect)
    local prototypeSprite = PrototypeSprite(.3, 0, .7, 16, 16)
    self:add(SpriteRenderer(prototypeSprite))
  end
}

function Player:update(dt)
  GameEntity.update(self, dt)
  local inputX, inputY = 0, 0
  if input:down('left') then
    inputX = inputX - 1
  end
  if input:down('right') then
    inputX = inputX + 1
  end
  if input:down('up') then
    inputY = inputY - 1
  end
  if input:down('down') then
    inputY = inputY + 1
  end
  self:setVector(inputX, inputY)
  self:move(dt)
end

return Player
