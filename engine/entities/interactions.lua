local ProjectileType = require 'engine.enums.projectile_type'

-- NB: this module is purposely nontyped

--- interactions are functions that can be used to resolve interactions between entities
--- see engine/components/interaction_resolver.lua
--- all functions here assume the receiver and sender are Entity's that implement the InteractionResolver api. 
--- See engine/entities/map_entity.lua and engine/entities/projectile/projectile.lua for examples of this api implemented in entities
local Interactions = { }

--- receiver ignores the interaction
--- Note that this still counts as an interaction. See ItemShield:triggerOverrideInteractions() as an example
function Interactions.ignore(receiver, sender)
  -- do nothing
end



--- receiver takes damage from sender
function Interactions.takeDamage(receiver, sender)
  if not (receiver.entity.isIntangible and receiver.entity:isIntangible()) then
    if receiver.entity.hurt then
      if receiver.entity.triggerOverrideInteractions and receiver.entity:triggerOverrideInteractions(sender) then
        return  -- exit out early
      end
      receiver.entity:hurt(sender:getDamageInfo())
      sender:notifyDidDamage(receiver)
    end
  end
end

--- hurt the sender entity
function Interactions.damageOther(receiver, sender)
  if not (sender.entity.triggerOverrideInteractions and sender.entity:triggerOverrideInteractions(receiver)) then
    if not (sender.entity.isIntangible and sender.entity:isIntangible()) then
      sender.entity:hurt(receiver:getDamageInfo())
      receiver:notifyDidDamage(sender)
    end
  end
end

--- deflect the sender if its a projectile or it has a :deflect() method
function Interactions.deflect(receiver, sender)
  if receiver.projectileType then
    if receiver.projectileType == ProjectileType.notDeflectable then
      return
    end
    -- TODO weapon level logic here
  end

  if receiver.deflect then
    receiver:deflect()
  end
end

--- intercept the sender if its a projectile or it has a :intercept() method. Typically
--- this is used for projectiles to cause them to crash or be destroyed
function Interactions.intercept(receiver, sender)
  if sender.intercept then
    sender:intercept()
  end
end

--- receiver entity bumps off the sender
function Interactions.knockback(receiver, sender)
  if receiver.entity and receiver.entity.knockback then
    local senderEntity = sender.entity
    local senderX, senderY = senderEntity:getPosition()
    

    local speed = 60 -- TODO maybe this should be based on the attack or something?
    local time = 0.2
    
  end
end



return Interactions