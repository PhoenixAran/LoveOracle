local Class = require 'lib.class'
local Component = require 'engine.entities.component'

local InteractionResolver = Class { __includes = Component,
  init = function(self, entity, args)
    if args == nil then
      args = { }
    end
    Component.init(self, entity, args)
    self.interactions = { }
  end
}

function InteractionResolver:getType()
  return 'interaction_resolver'
end

function InteractionResolver:setInteraction(tag, interaction)
  self.interactions[tag] = interaction
end

function InteractionResolver:removeInteraction(tag)
  self.interactions[tag] = nil
end

function InteractionResolver:getInteraction(tag)
  return self.interactions[tag]
end

function InteractionResolver:resolveInteraction(receiver, sender)
  local tag = receiver:getCollisionTag()
  local interaction = self:getInteraction(tag)
  if interaction then
    interaction(receiver, sender)
  end
end

return InteractionResolver