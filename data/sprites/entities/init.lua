local path = ...
return makeModuleFunction(function(spriteBank)
  require(path .. '.monster_items')(spriteBank)
  require(path .. '.stalfos_sprite')(spriteBank)
end)