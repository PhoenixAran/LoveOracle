local Class = require 'lib.class'
local GameEntity = require 'engine.entities.game_entity'
local PrototypeSprite = require 'engine.graphics.prototype_sprite'
local SpriteRenderer = require 'engine.components.sprite_renderer'
local PlayerStateMachine = require 'data.player.player_state_machine'

local Player = Class { __includes = GameEntity,
  init = function(self, enabled, visible, rect) 
    GameEntity.init(self, enabled, visible, rect)
    
    -- declarations
    self.environmentStateMachine = PlayerStateMachine()
    
    
    
    self.useDirectionX, self.useDirectionY = 0
    self.respawnPositionX, self.respawnPositionY = nil, nil
    self.respawnDirection = nil
    self.moveAnimation = nil
  
    -- add components
    local prototypeSprite = PrototypeSprite(.3, 0, .7, 16, 16)
    self:add(SpriteRenderer(prototypeSprite))
  end
}


function Player:update(dt)
  GameEntity.update(self, dt)
end


return Player
