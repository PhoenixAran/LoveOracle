local Class = require 'lib.class'
local lume = require 'lib.lume'

local MapEditorActionStack = Class {
  init = function(self)
    self.index = 0
    self.actions = { }
  end
}

function MapEditorActionStack:getType()
  return 'map_editor_action_stack'
end

function MapEditorActionStack:addAction(action)
  if action:isValid() then
    lume.push(self.actions, action)
    local count = lume.count(self.actions)
    if self.index == count - 1 then
      self.index = count
    end
  end
end

function MapEditorActionStack:redo()
  local count = lume.count(self.actions)
  if 0 < count and self.index <= count then
    self.actions[self.index]:redo()
    self.index = math.min(self.index + 1, count)
  end
end

function MapEditorActionStack:undo()
  local count = lume.count(self.actions)
  if 0 < count and 0 < self.index then
    local action = self.actions[self.index]
    action:undo()
    self.index = math.max(self.index - 1, 1)
  end
end

return MapEditorActionStack