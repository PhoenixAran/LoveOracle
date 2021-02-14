local path = ...
local moduleFunction = function(tilesetBank)
  require(path .. '.prototype_tileset')(tilesetBank)
end
return makeModuleFunction(moduleFunction)