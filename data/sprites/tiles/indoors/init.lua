local path = ...
return function(spriteBank)
  require(path .. '.cracked_floors')(spriteBank)
  require(path .. '.entrances')(spriteBank)
end