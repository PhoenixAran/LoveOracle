local version = '0.0.20.0'
local controls = {
  controls = {
    left = {'key:left', 'axis:leftx-', 'button:dpleft'},
    right = {'key:right','axis:leftx+', 'button:dpright'},
    up = {'key:up', 'axis:lefty-', 'button:dpup'},
    down = {'key:down', 'axis:lefty+', 'button:dpdown'}, 

    a = {'key:space', 'button:a'},
    b = {'key:c', 'button:b' },
    x = {'key:x', 'button:y' },
    y = {'key:z', 'button:x'},

    leftShoulder = {'key:lshift', 'button:leftshoulder'},
    leftTrigger = {'key:i', 'axis:triggerleft+'},

    rightShoulder = {'key:lctrl', 'button:rightshoulder'},
    rightTrigger = {'key:o', 'axis:triggerright+'},


    leftClick = { 'mouse:1' },
    start = { 'key:p', 'button:start'},
    select = {'key:k', 'button:back'}
  },

  pairs = {
    move = { 'left', 'right', 'up', 'down' }
  },
  joystick = love.joystick.getJoysticks()[1],
  deadzone = 0.33
}

local window = {
  title = "Love Oracle " .. version,
  displayConfig = {
    gameWidth = 256,
    gameHeight = 144,
    virtualWidth = 1024,
    virtualHeight = 576
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