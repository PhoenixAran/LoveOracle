local path = ...
return function(TileData)
  require(path .. '.default_tiles')(TileData)
end