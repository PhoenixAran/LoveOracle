-- Make sure we are using luaJIT
assert(require('ffi'), 'LoveOracle requires luaJIT')
local lume = require 'lib.lume'
local gameConfig = require 'game_config'
local ContentControl = require 'engine.utils.content_control'
local AssetManager = require 'engine.utils.asset_manager'
local tick = require 'lib.tick'

love.inspect = require 'lib.inspect'

-- singletons
local Input = require 'engine.singletons.input'
local Camera = require 'engine.singletons.camera'
local ScreenManager = require 'engine.singletons.screen_manager'
local Monocle = require 'engine.singletons.monocle'

-- init quake console
require 'lib.console'
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

function love.load(args)
  tick.framerate = 60
  tick.rate = 1 / 60
  ContentControl.buildContent()

  --[[
    Singleton Inits
  ]]
  ScreenManager.setInstance(require('lib.roomy').new())
  ScreenManager.getInstance():hook({ exclude = {'update','draw', 'resize', 'load'} })
  Camera.setInstance(require('lib.camera')(0,0, 160, 144))
  Input.setInstance(require('lib.baton').new(gameConfig.controls))
  local monocleInstance = require('lib.monocle').new()
  monocleInstance:setup(gameConfig.window.monocleConfig, gameConfig.window.windowConfig)
  Monocle.setInstance(monocleInstance)

  love.graphics.setDefaultFilter('nearest', 'nearest')
  love.window.setTitle(gameConfig.window.title)
  love.graphics.setFont(AssetManager.getFont('monogram'))


  print('Startup Screen: ' .. gameConfig.startupScreen)
  if gameConfig.showSplash then
    ScreenManager.getInstance():enter( require('engine.screens.splash_screen')(gameConfig.startupScreen))
  else
    ScreenManager.getInstance():enter( require(gameConfig.startupScreen)() )
  end

  local Slab = require 'lib.slab'
  Slab.SetINIStatePath(nil)
  Slab.Initialize()
end

function love.update(dt)
  ScreenManager.instance:emit('update', dt)
end

function love.draw()
  ScreenManager.instance:emit('draw')
end

function love.resize(w, h)
  Monocle.instance:resize(w, h)
  ScreenManager.instance:emit('resize', w, h)
end