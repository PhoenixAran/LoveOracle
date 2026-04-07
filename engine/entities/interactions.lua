local ProjectileType = require 'engine.enums.projectile_type'

-- NB: this module is purposely nontyped

--- interactions are functions that can be used to resolve interactions between entities via hitboxes
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
function Interactions.damageSelf(receiver, sender)
  if not (receiver.entity.isIntangible and receiver.entity:isIntangible()) then
    if receiver.entity.hurt then
      if receiver.entity.triggerOverrideInteractions and receiver.entity:triggerOverrideInteractions(sender) then
        return  -- exit out early
      end
      receiver.entity:hurt(sender:getDamageInfo())
      sender:notifyHitOther(receiver)
    end
  end
end

--- hurt the sender entity
function Interactions.damageOther(receiver, sender)
  if not (sender.entity.triggerOverrideInteractions and sender.entity:triggerOverrideInteractions(receiver)) then
    if not (sender.entity.isIntangible and sender.entity:isIntangible()) then
      sender.entity:hurt(receiver:getDamageInfo())
      receiver:notifyHitOther(sender)
    end
  end
end

--- deflect the sender if its a projectile or it has a :deflect() method
function Interactions.deflectSelf(receiver, sender)
  local senderProjectile = receiver.entity
  if senderProjectile.projectileType then
    if senderProjectile.projectileType == ProjectileType.notDeflectable then
      return
    end
    -- TODO weapon level logic here
  end

  if senderProjectile.deflect then
    senderProjectile:deflect()
  end
end

--- intercept the sender if its a projectile or it has a :intercept() method. Typically
--- this is used for projectiles to cause them to crash or be destroyed
function Interactions.interceptSelf(receiver, sender)
  local senderProjectile = sender.entity
  if senderProjectile.intercept then
    senderProjectile:intercept()
  end
end

--- receiver entity bumps off the sender
function Interactions.knockbackSelf(receiver, sender)
  if receiver.entity and receiver.entity.knockback then
    local senderKnockbackInfo = sender:getDamageInfo()
    receiver.entity:knockback(senderKnockbackInfo)
    sender:notifyHitOther(receiver)
  end
end

--- receiver entity gets stunned by sender
--- NB: receiver should inherit from enemy or have its own implementation of :stun() method for this to work
function Interactions.stunSelf(receiver, sender)
  if receiver.entity and receiver.entity.stun then
    local senderDamageInfo = sender:getDamageInfo()
    receiver.entity:stun(senderDamageInfo)
    sender:notifyHitOther(receiver)
  end
end



return Interactions