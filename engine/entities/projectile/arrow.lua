local Class = require 'lib.class'
local Projectile require 'engine.entities.projectile.projectile'
local lume = require 'lib.lume'
local vector = require 'engine.math.vector'
local Interactions = require 'engine.entities.interactions'
local CollisionTag = require 'engine.enums.collision_tag'
local ProjectileTag 

---@class Arrow : Projectile
local Arrow = Class { __includes = Projectile,
  ---@param self Arrow
  ---@param args table
  init = function(self, args)
    -- Initialization code here
    
    Projectile.init(self, args)

    self.interactionResolver:setInteraction(CollisionTag.player, Interactions.damageOther)
    self.interactionResolver:setInteraction(CollisionTag.sword, Interactions.deflect)
    self.interactionResolver:setInteraction(CollisionTag.shield, Interactions.deflect)
  end
}


function Arrow:getType()
  return 'arrow'
end


function Arrow:onAwake()
  Projectile.onAwake(self)
  self.sprite:play('shoot')
end

function Arrow:onCrash()
  Projectile.onCrash(self)
end

return Arrow                                                    