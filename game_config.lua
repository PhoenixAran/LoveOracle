local version = '0.0.7.0'
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
    virtualWidth = 1280,
    virtualHeight = 720,
    maxScale = 4
  },
  windowConfig = {
    minwidth = 800,
    minheight = 600,
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


local startupScreen = 'engine.test_screens.physics_test'
return {
 zbStudioDebug = zbStudioDebug,
 controls = controls,
 window = window,
 startupScreen = startupScreen,
 version = version,
 physicsFlags = physicsFlags
}