local path = ...
return function(tilesetBank)
  require(path .. '.prototype_tileset')(tilesetBank)
end