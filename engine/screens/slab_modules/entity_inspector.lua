local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local lume = require 'lib.lume'
local Slab = require 'lib.slab'
local PropertyType = require('engine.entities.inspector_properties').PropertyType
local InspectorPropertyFields = require 'engine.screens.slab_modules.inspector_property_fields'

---@class EntityInspector
---@field entities Entities
---@field currentEntity Entity
---@field searchText string
local EntityInspector = Class { __includes = SignalObject,
  init = function(self, entities)
    self.entities = entities
    self.currentEntity = nil
    self.searchText = ''
  end
}

function EntityInspector:update(dt)
  Slab.BeginWindow('EntityInspector', { Title = 'Entity Inspector' })
  Slab.Text('Entity Search')
  if Slab.Input('EntitySearch', { Text = self.searchText, ReturnOnText = true}) then
    self.searchText = Slab.GetInputText()
  end
  Slab.Separator()
  self.currentEntity = self.entities:getByName(self.searchText:gsub("^%s*(.-)%s*$", "%1"))
  if self.currentEntity then
    local props = self.currentEntity:getInspectorProperties()
    InspectorPropertyFields.makePropertyFields(props, self.currentEntity:getName())
  end
  Slab.EndWindow()
end

return EntityInspector