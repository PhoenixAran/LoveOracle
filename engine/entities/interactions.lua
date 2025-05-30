-- interactinos are functions that can be used to resolve interactions between entities
-- see engine/components/interaction_resolver.lua
local Interactions = { }

function Interactions.ignore(receiver, sender)
  -- do nothing
end

function Interactions.takeDamage(receiver, sender)
  if not (receiver.entity.isIntangible and receiver.entity:isIntangible()) then
    if receiver.entity.hurt then
      receiver.entity:hurt(sender:getDamageInfo())
      sender:notifyDidDamage(receiver)
    end
  end
end

function Interactions.damageOther(receiver, sender)
  if not (sender.entity.triggerOverrideInteractions and sender.entity:triggerOverrideInteractions(receiver)) then
    if not (sender.entity.isIntangible and sender.entity:isIntangible()) then
      sender.entity:hurt(receiver:getDamageInfo())
      receiver:notifyDidDamage(sender)
    end
  end
end

return Interactions

