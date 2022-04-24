local singletons = {
  input = nil,
  monocle = nil,
  screenManager = nil,
  camera = nil
}

function singletons.getType()
  return 'singletons'
end

return singletons