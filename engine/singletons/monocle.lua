local MonocleSingleton = { 
  instance = nil
}

function MonocleSingleton.getInstance()
  return MonocleSingleton.instance
end

function MonocleSingleton.setInstance(instance)
  MonocleSingleton.instance = instance
end

return MonocleSingleton