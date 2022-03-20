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
    move = { 'left', 'right', 'up', 'down'}
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

local showSplash = false

-- Do not exceed 32 flags!
local physicsFlags = {
  'entity',
  'player',
  'enemy',
  'npc',
  'platform',
  'tile',
  'room_edge'
}

--local startupScreen = 'engine.test_screens.animated_sprite_renderer_test'
--local startupScreen = 'engine.test_screens.sprite_sheet_test'
--local startupScreen = 'engine.test_screens.draw_tilemap_test'
--local startupScreen = 'engine.test_screens.tiled_map_loader_test'
--local startupScreen = 'engine.screens.content_viewer'
--local startupScreen = 'data.test_screens.player_playground'
--local startupScreen = 'engine.test_screens.entity_inspector_test'
--local startupScreen = 'engine.test_screens.physics_test'
--local startupScreen = 'engine.test_screens.game_control_test'
--local startupScreen = 'engine.test_screens.raycast_test'
local startupScreen = 'data.test_screens.player_sword_hitbox_test'

return {
  showSplash = showSplash,
  controls = controls,
  window = window,
  startupScreen = startupScreen,
  version = version,
  physicsFlags = physicsFlags,
}