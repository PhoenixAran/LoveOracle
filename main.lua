local lume = require 'lib.lume'
local gameConfig = require 'game_config'
local ContentControl = require 'engine.utils.content_control'
local AssetManager = require 'engine.utils.asset_manager'
local tick = require 'lib.tick'
local DisplayHandler = require 'engine.display_handler'
love.inspect = require 'lib.inspect'
-- singletons
local Singletons = require 'engine.singletons'

-- init quake console
require 'lib.console'
require 'engine.console_commands'

print('Ziggy Engine ' .. gameConfig.version)
print('   |\\|\\')
print('  ..    \\       .')
print('o--     \\\\    / @)')
print(' v__///\\\\\\\\__/ @')
print('   {           }')
print('    {  } \\\\\\{  }')
print('    <_|      <_|')

print()

print("OS: " .. love.system.getOS())
print(('Renderer: %s %s\nVendor: %s\nGPU: %s'):format(love.graphics.getRendererInfo()))
print('Save Directory: ' .. love.filesystem.getSaveDirectory())

print()

--[[
     Defining helper function used in data scripting
     Hot reloading can't modify existing functions, but it works with tables.
     To work around this, this function will create a metatable that is callable.
]]
function makeModuleFunction(func)
  local function dropSelfArg(func)
    return function(...)
      return func(select(2, ...))
    end
  end
  return setmetatable({}, {__call = dropSelfArg(func)})
end

---@type any
local screenManager = nil
local input = nil

function love.load(args)
  -- graphics setup
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle(gameConfig.window.title)

  -- build content here (need it for font)
  ContentControl.buildContent()
  love.graphics.setFont(AssetManager.getFont('baseScreenDebug'))

  -- set up tick rate
  tick.rate = 1 / 60
  tick.framerate = 60
  local _, _, windowFlags = love.window.getMode()
  if windowFlags.refreshrate then
    tick.framerate = math.max(tick.framerate, windowFlags.refreshrate)
  end

  --[[
    Singleton Inits
  ]]
  -- set up screen manager
  screenManager = require('lib.roomy').new()
  screenManager:hook({ exclude = {'update','draw', 'resize', 'load'} })
  Singletons.screenManager = screenManager

  -- set up input
  input = require('lib.baton').new(gameConfig.controls)
  Singletons.input = input

  -- set up display handler

  DisplayHandler.init({
    -- display handler arguments
    canvasWidth = gameConfig.window.displayConfig.virtualWidth,
    canvasHeight = gameConfig.window.displayConfig.virtualHeight,

    -- resolution solution arguments
    game_width = gameConfig.window.displayConfig.gameWidth,
    game_height = gameConfig.window.displayConfig.gameHeight,
    scale_mode = 1
  })
  -- set up console
  love.keyboard.setKeyRepeat(true)
  --console.font = AssetManager.getFont('debugConsole')

  -- setup startup screen
  print('Startup Screen: ' .. gameConfig.startupScreen)
  screenManager:enter(require(gameConfig.startupScreen)())
end

function love.update(dt)
  screenManager:emit('update', dt)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.draw()
  screenManager:emit('draw')
end

function love.resize(w, h)
  screenManager:emit('resize', w, h)
  DisplayHandler.resize(w, h)
end