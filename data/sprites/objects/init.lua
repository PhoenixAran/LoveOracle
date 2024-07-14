local path = ...
return makeModuleFunction(function(spriteBank)
  require(path .. '.platforms')(spriteBank)
end)