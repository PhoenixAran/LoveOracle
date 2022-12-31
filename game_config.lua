local version = '0.0.15.1'
local controls = {
  controls = {
    left = {'key:left', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right','axis:leftx+', 'button:dpright'},
    up = {'key:up', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'axis:lefty+', 'button:dpdown'}, 
    a = {'key:space', 'button:b'},
    b = {'key:c', 'button:a'},
    x = {'key:x', 'button:y' },
    y = {'key:z', 'button:x'},
    leftClick = { 'mouse:1' }
  },
  pairs = {
    move = { 'left', 'right', 'up', 'down' }
  },
  joystick = love.joystick.getJoysticks()[1]
}

local window = {
  title = "Love Oracle " .. version,
  monocleConfig = {
    windowWidth = 160,
    windowHeight = 144,
    virtualWidth = 1280,
    virtualHeight = 720,
    maxScale = 6
  },
  windowConfig = {
    minwidth = 160,
    minheight = 144,
    vsync = true,
    resizable = true
  }
}

local showSplash = false

--local startupScreen = 'engine.test_screens.game_control_test'
local startupScreen = 'engine.test_screens.helium_test'

local enableQuakeConsole = true
return {
  showSplash = showSplash,
  controls = controls,
  window = window,
  startupScreen = startupScreen,
  version = version,
  enableQuakeConsole = enableQuakeConsole
}