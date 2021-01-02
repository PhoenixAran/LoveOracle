local version = '0.0.6.0'
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
    y = {'key:h', 'button:x'},
    leftClick = { 'mouse:1' }
  },
  joystick = love.joystick.getJoysticks()[1]
}

local window = {
  title = "Love Oracle " .. version,
  monocleConfig = {
    windowWidth = 160,
    windowHeight = 144,
    virtualWidth = 160 * 4,
    virtualHeight = 144 * 4,
    maxScale = 100
  },
  windowConfig = {
    minwidth = 144,
    minheight = 160,
    vsync = true,
    resizable = true
  }
}

local physicsFlags = {
  'entity',
  'player',
  'enemy',
  'npc'
}


--local startupScreen = 'data.test_screens.player_playground'
local startupScreen = 'engine.test_screens.signal_test'
return {
 zbStudioDebug = zbStudioDebug,
 controls = controls,
 window = window,
 startupScreen = startupScreen,
 version = version
}