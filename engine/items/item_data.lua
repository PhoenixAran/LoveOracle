local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'

-- Class that ItemSlot will utilise
local ItemData = Class {
  init = function(self, itemId, category, name)
    assert(itemId, 'Item ID cannot be null')
    SignalObject.init(self)
    self.name = nil
    self.category = category
    self.itemId = itemId
    self.maxLevel = 0
    self.menuSprites = { }
    self.itemTypes = { }
    -- todo
    -- descriptions
  end
}

function ItemData:getName()
  return self.name
end

function ItemData:setName(name)
  self.name = name
end

function ItemData:getType()
  return 'item_data'
end

function ItemData:getItemId()
  return self.itemId
end

function ItemData:isLeveled()
  return self.maxLevel > 0
end

function ItemData:setMaxLevel(level)
  if level then
    self.maxLevel = level
  else
    self.maxLevel = 0
  end
end

function ItemData:setMenuSprites(sprites)
  if type(sprites) == 'table' then
    lume.push(self.sprites, unpack(sprites))
  else
    lume.push(self.sprites, sprites)
  end
end

function ItemData:getMenuSprites()
  return self.sprites
end

function ItemData:setItemTypes(types)
  if type(types) == 'table' then
    lume.push(self.types, unpack(types))
  else
    lume.push(self.types, types)
  end
end

return ItemData
