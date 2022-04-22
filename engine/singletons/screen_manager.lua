local ScreenManagerSingleton = {
  instance = nil
}

function ScreenManagerSingleton.getInstance()
  return ScreenManagerSingleton.instance
end

function ScreenManagerSingleton.setInstance(instance)
  ScreenManagerSingleton.instance = instance
end

return ScreenManagerSingleton