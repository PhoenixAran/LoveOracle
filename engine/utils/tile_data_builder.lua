local Class = require 'lib.class'
local lume = require 'lib.lume'

local Templates = { }

local TileDataBuilder = Class {
  init = function(self)
    
  end
}

function TileDataBuilder:getType()
  return 'tile_data_builder'
end

-- templates
function TileDataBuilder.addTemplate(name, tileDataBuilder)
  assert(not Templates[name], 'Tile Template with name ' .. name .. ' already exists')
  Templates[name] = tileDataBuilder
end

function TileDataBuilder.initializeTemplates(path)
  path = path or 'data.tile_templates'
  require(path)(Templates)
end

function Templates.createFromTemplate(name)
  assert(Templates[name], 'Tile Template with name ' .. name .. ' does not exist')
  return Templates[name]:clone()
end
-- end templates


return TileDataBuilder