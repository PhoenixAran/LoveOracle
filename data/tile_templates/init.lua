local path = ...
local moduleFunction = function(TileData)
  require(path .. '.default_tiles')(TileData)
end
return makeModuleFunction(moduleFunction)