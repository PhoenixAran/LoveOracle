-- Make sure we are using luaJIT
assert(require('ffi'), 'LoveOracle requires luaJIT')
local lume = require 'lib.lume'
local gameConfig = require 'game_config'
local ContentControl = require 'engine.utils.content_control'
local AssetManager = require 'engine.utils.asset_manager'
local tick = require 'lib.tick'

love.inspect = require 'lib.inspect'

-- singletons
local Singletons = require 'engine.singletons'

-- init quake console
local console = require 'lib.console'
require 'engine.console_commands'
-- not really max, just an unrealistically high number
math.maxinteger = 1000000000000000000000000000000000000000000000
-- same as above but negative
math.mininteger = -math.maxinteger
math.randomseed(os.time())

print('Oracle Engine ' .. gameConfig.version)
print("OS: " .. love.system.getOS())
print(('Renderer: %s %s\nVendor: %s\nGPU: %s'):format(love.graphics.getRendererInfo()))
print('Save Directory: ' .. love.filesystem.getSaveDirectory())

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


local screenManager = nil
local camera = nil
local input = nil
local monocle = nil

function love.load(args)
  -- graphics setup
  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle(gameConfig.window.title)
  -- build content here (need it for font)
  ContentControl.buildContent()
  love.graphics.setFont(AssetManager.getFont('baseScreenDebug'))
  

  -- set up tick rate
  tick.framerate = 60
  tick.rate = 1 / 60

  --[[
    Singleton Inits
  ]]
  -- set up screen manager
  screenManager = require('lib.roomy').new()
  screenManager:hook({ exclude = {'update','draw', 'resize', 'load'} })
  Singletons.screenManager = screenManager

  -- set up camera
  camera = require('lib.camera')(0, 0, 160, 144)
  Singletons.camera = camera

  -- set up input
  input = require('lib.baton').new(gameConfig.controls)
  Singletons.input = input

  -- set up monocle
  monocle = require('lib.monocle').new()
  monocle:setup(gameConfig.window.monocleConfig, gameConfig.window.windowConfig)
  Singletons.monocle = monocle

  -- set debug console font
  console.font = AssetManager.getFont('debugConsole')

  -- setup startup screen
  print('Startup Screen: ' .. gameConfig.startupScreen)
  if gameConfig.showSplash then
    screenManager:enter( require('engine.screens.splash_screen')(gameConfig.startupScreen))
  else
    screenManager:enter( require(gameConfig.startupScreen)() )
  end
  local Slab = require 'lib.slab'
  Slab.SetINIStatePath(nil)
  Slab.Initialize()
end

function love.update(dt)
  screenManager:emit('update', dt)
end

function love.draw()
  screenManager:emit('draw')
end

function love.resize(w, h)
  monocle:resize(w, h)
  screenManager:emit('resize', w, h)
end