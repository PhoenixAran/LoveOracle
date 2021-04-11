local Class = require 'lib.class'

local MapEditorActionStack = Class {
  init = function(self)
    self.actionIndex = 1
    self.actions = { }
  end
}

function MapEditorActionStack:getType()
  return 'map_editor_action_stack'
end

function MapEditorActionStack:addAction(action)

end

function MapEditorActionStack:redo()

end

function MapEditorActionStack:undo()

end

return MapEditorActionStack