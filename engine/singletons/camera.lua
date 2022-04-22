local CameraSingleton = {
  instance = nil
}

function CameraSingleton.getInstance()
  return CameraSingleton.instance
end

function CameraSingleton.setInstance(instance)
  CameraSingleton.instance = instance
end

return CameraSingleton