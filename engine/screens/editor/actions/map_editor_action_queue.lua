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
    local oldCount = lume.count(self.actions)
    lume.push(self.actions, action)
    local newCount = lume.count(self.actions)
    if self.index == oldCount then
      self.index = newCount
    else
      self.index = self.index + 1
      for i = self.index, newCount do
        self.actions[i] = nil
      end
    end
  end
end

function MapEditorActionStack:redo()
  local count = lume.count(self.actions)
  print(self.index)
  if 0 < count and self.index <= count then
    self.actions[self.index]:redo()
    self.index = math.min(self.index + 1, count)
  end
end

function MapEditorActionStack:undo()
  local count = lume.count(self.actions)
  print(self.index)
  if 0 < count then
    local action = self.actions[self.index]
    action:undo()
    self.index = math.max(self.index - 1, 1)
  end
end

return MapEditorActionStack