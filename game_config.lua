local controls = {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'}
  },
  pairs = {
    move = {'left', 'right', 'up', 'down'}
  },
  joystick = love.joystick.getJoysticks()[1]
}

local window = {
  title = "Love Oracle Alpha 0.01",
  width = 160, 
  height = 144, 
  virtualWidth = 160 * 4,
  virtualHeight = 144 * 4,
  windowConfig = {
    minwidth = 160,
    minheight = 144,
    vsync = true,
    resizable = true
  }
}

function window.getMonocleArguments()
  return window.width, window.height, window.virtualWidth, window.virtualHeight, window.windowConfig
end

local startupScreen = "engine.test_screens.sprite_test"

return {
 controls = controls,
 window = window,
 startupScreen = startupScreen
}