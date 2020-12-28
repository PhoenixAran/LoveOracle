local version = '0.0.4.0'
local zbStudioDebug = true  -- enable breakpoint and step through with zbstudio

-- Made for SNES controllers
local controls = {
  controls = {
    left = {'key:left', 'key:a', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right', 'key:d', 'axis:leftx+', 'button:dpright'},
    up = {'key:up', 'key:w', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'key:s', 'axis:lefty+', 'button:dpdown'}, 
    a = {'key:n', 'button:b'},
    b = {'key:b', 'button:a'},
    x = {'key:j', 'button:y' },
    y = {'key:h', 'button:x'}
  },
  joystick = love.joystick.getJoysticks()[1]
}

local window = {
  title = "Love Oracle " .. version,
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

local startupScreen = 'data.test_screens.player_playground'
--local startupScreen = 'engine.test_screens.slab_test_screen'

function window.getMonocleArguments()
  return window.width, window.height, window.virtualWidth, window.virtualHeight, window.windowConfig
end

return {
 zbStudioDebug = zbStudioDebug,
 controls = controls,
 window = window,
 startupScreen = startupScreen,
 version = version
}