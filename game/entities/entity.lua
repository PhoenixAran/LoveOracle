local Class = require 'lib.class'
local Transform = require 'lib.transform'
local Vector = require 'lib.vector'
local ComponentList = require './component_list'

local Entity = Class {
  init = function(self, x, y)
    if x == nil then x = 0 end
    if y == nil then y = 0 end
    
    self.componentList = ComponentList(self)
    self.transform = Transform.new()
    self.transform:setPosition(x, y)
  end
}

function Entity:getType()
  return "entity"
end

return Entity