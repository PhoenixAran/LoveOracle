local ProjectileType = require 'engine.enums.projectile_type'


-- interactinos are functions that can be used to resolve interactions between entities
-- see engine/components/interaction_resolver.lua
local Interactions = { }

function Interactions.ignore(receiver, sender)
  -- do nothing
end



--- receiver takes damage from sender
function Interactions.takeDamage(receiver, sender)
  if not (receiver.entity.isIntangible and receiver.entity:isIntangible()) then
    if receiver.entity.hurt then
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

--- deflect the sender if its a projectile
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

--- intercept the sender if it has :intercept() method. Typically
--- this is used for projectiles to cause them to crash or be destroyed
function Interactions.intercept(receiver, sender)
  if sender.intercept then
    sender:intercept()
  end
end



return Interactions

