local version = '0.0.12.1'
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
    maxScale = 6
  },
  windowConfig = {
    minwidth = 800,
    minheight = 600,
    vsync = true,
    resizable = true
  }
}

-- Do not exceed 32 flags!
local physicsFlags = {
  'entity',
  'player',
  'enemy',
  'npc',
  'platform',
  'tile'
}

local tilesetThemeRequirements = {
  'prototype_a',
  'prototype_b',
}

local startupScreen = 'engine.screens.content_viewer'
--local startupScreen = 'data.test_screens.player_playground'

return {
 zbStudioDebug = zbStudioDebug,
 controls = controls,
 window = window,
 startupScreen = startupScreen,
 version = version,
 physicsFlags = physicsFlags,
 tilesetThemeRequirements = tilesetThemeRequirements
}