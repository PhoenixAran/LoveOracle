local GameControl = {
  instance = nil
}

function GameControl.setInstance(value)
  GameControl.instance = value
end

function GameControl.getInstance()
  return GameControl.instance
end

return GameControl