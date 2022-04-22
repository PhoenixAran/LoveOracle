local InputSingleton = {
  instance = nil
}

function InputSingleton.getInstance()
  return InputSingleton.instance
end

function InputSingleton.setInstance(instance)
  InputSingleton.instance = instance
end

return InputSingleton