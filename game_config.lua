local version = '0.0.17.0'
local controls = {
  controls = {
    left = {'key:left', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right','axis:leftx+', 'button:dpright'},
    up = {'key:up', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'axis:lefty+', 'button:dpdown'}, 
    a = {'key:space', 'button:a'},
    b = {'key:z', 'button:b'},
    x = {'key:x', 'button:y' },
    y = {'key:c', 'button:x'},
    leftClick = { 'mouse:1' }
  },
  pairs = {
    move = { 'left', 'right', 'up', 'down' }
  },
  joystick = love.joystick.getJoysticks()[1]
}

local window = {
  title = "Love Oracle " .. version,
  displayConfig = {
    gameWidth = 160,
    gameHeight = 144,
    virtualWidth = 1280,
    virtualHeight = 720
  }
}

local showSplash = false

local startupScreen = 'engine.test_screens.game_control_test'
--local startupScreen = 'engine.screens.content_viewer'
--local startupScreen = 'engine.test_screens.signal_test'

local enableQuakeConsole = true
return {
  showSplash = showSplash,
  controls = controls,
  window = window,
  startupScreen = startupScreen,
  version = version,
  enableQuakeConsole = enableQuakeConsole
}