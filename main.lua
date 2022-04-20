local Monocle = require 'lib.monocle'
local lume = require 'lib.lume'
local gameConfig = require 'game_config'
local ContentControl = require 'engine.utils.content_control'
local AssetManager = require 'engine.utils.asset_manager'
local tick = require 'lib.tick'

-- Make sure we are using luaJIT
assert(require('ffi'), 'LoveOracle requires luaJIT')

-- init quake console
require 'lib.console'
require 'lib.console.console_commands'

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

love.inspect = require 'lib.inspect'

function makeModuleFunction(func)
  local function dropSelfArg(func)
    return function(...)
      return func(select(2, ...))
    end
  end
  return setmetatable({}, {__call = dropSelfArg(func)})
end

local vec2 = require 'lib.vector'
local tx, ty = vec2.normalize(.552, .287)
print(vec2.snapDirectionByCount(tx, ty, 32))

function love.load(args)
  tick.framerate = 60
  tick.rate = 1 / 60
  ContentControl.buildContent()
  --[[
    GLOBALS DECLARED HERE
  ]]
  screenManager = require('lib.roomy').new()
  camera = require('lib.camera')(0,0, 160, 144)
  input = require('lib.baton').new(gameConfig.controls)
  monocle = Monocle.new()
  monocle:setup(gameConfig.window.monocleConfig, gameConfig.window.windowConfig)
  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle(gameConfig.window.title)
  love.graphics.setFont(AssetManager.getFont('monogram'))
  screenManager:hook({ exclude = {'update','draw', 'resize', 'load'} })
  print(gameConfig.startupScreen)
  if gameConfig.showSplash then
    screenManager:enter( require('engine.screens.splash_screen')(gameConfig.startupScreen))
  else
    screenManager:enter( require(gameConfig.startupScreen)())
  end
  local Slab = require 'lib.slab'
  Slab.SetINIStatePath(nil)
  Slab.Initialize()
end

function love.update(dt)
  input:update()
  screenManager:emit('update', dt)
end

function love.draw()
  screenManager:emit('draw')
end

function love.resize(w, h)
  monocle:resize(w, h)
  screenManager:emit('resize', w, h)
end