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
    self.index = self.index + 1
    self.actions[self.index] = action
    for i = self.index + 1, lume.count(self.actions) do
      self.actions[i] = nil
    end
  end 
end

function MapEditorActionStack:redo()
  local count = lume.count(self.actions)
  if 0 < count and self.index < count then
    self.index = math.min(self.index + 1, count)
    self.actions[self.index]:execute()
  end
end

function MapEditorActionStack:undo()
  local count = lume.count(self.actions)
  if 1 <= self.index then
    print(count, self.index)
    self.actions[self.index]:undo()
    self.index = math.max(0, self.index - 1)
  end
end

function MapEditorActionStack:clear()
  lume.clear(self.actions)
  self.index = 0
end

return MapEditorActionStack