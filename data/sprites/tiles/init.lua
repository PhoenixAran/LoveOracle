local path = ...
return function(spriteBank)
  require(path .. '.indoors')(spriteBank)
end