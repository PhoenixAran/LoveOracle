local path = ...
return makeModuleFunction(function(spriteBank)
  require(path .. '.stalfos_sprite')(spriteBank)
end)