local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'

-- class shows which menu the item will show up in, and what sprite and level to display
-- item resources will create Item entities when Inventory equips the item
local ItemData = Class { __includes = SignalObject,
  init = function(self, itemId, category)
    assert(itemId, 'Item ID cannot be null')
    SignalObject.init(self)
    self.category = category
    self.itemId = itemId
    self.level = -1
    self.itemCreatorFunc = nil
  end
}

function ItemData:getName()
  return 'Default Menu Item Name'
end

function ItemData:getType()
  return 'menu_item'
end

function ItemData:getItemId()
  return self.itemId
end

function ItemData:hasLevel()
  return self.level > 0
end

function ItemData:setLevel(level)
  self.level = level
end

function ItemData:setItemCreatorFunc(func)
  self.itemCreatorFunc = func
end

function ItemData:createItem()
  assert(func, 'MenuItem cannot create Item without Item Creation Function')
  return self.func()
end

return ItemData
