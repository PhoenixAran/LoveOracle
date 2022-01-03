local Monocle = require 'lib.monocle'
local lume = require 'lib.lume'
local gameConfig = require 'game_config'
local ContentControl = require 'engine.utils.content_control'
local AssetManager = require 'engine.utils.asset_manager'

-- Make sure we are using luaJIT
assert(require('ffi'), 'LoveOracle requires luaJIT')

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

function love.load(arg)
  -- enable zerobrane studio debugging
  if gameConfig.zbStudioDebug then
    if arg[#arg] == '-debug' then require('mobdebug').start() end
  end

  ContentControl.buildContent()

  --[[
    GLOBALS DECLARED HERE
  ]]
  screenManager = require('lib.roomy').new()
  camera = require('lib.camera')(0,0, 160, 144)
  input = require('lib.baton').new(gameConfig.controls)
  monocle = Monocle.new()
  monocle:setup(gameConfig.window.monocleConfig, gameConfig.window.windowConfig)


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

-- MAIN LOOP
-- 1 / Ticks Per Second
local TICK_RATE = 1 / 60

-- How many Frames are allowed to be skipped at once due to lag (no "spiral of death")
local MAX_FRAME_SKIP = 25

-- No configurable framerate cap currently, either max frames CPU can handle (up to 1000), or vsync'd if conf.lua
function love.run()
---@diagnostic disable-next-line: undefined-field, redundant-parameter
  if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

  -- We don't want the first frame's dt to include time taken by love.load.
  if love.timer then love.timer.step() end

  local lag = 0.0

  -- Main loop time.
  return function()
    -- Process events.
    if love.event then
      love.event.pump()
      for name, a,b,c,d,e,f in love.event.poll() do
        if name == "quit" then
          if not love.quit or not love.quit() then
              return a or 0
          end
        end
---@diagnostic disable-next-line: undefined-field
        love.handlers[name](a,b,c,d,e,f)
      end
    end

    -- Cap number of Frames that can be skipped so lag doesn't accumulate
    if love.timer then
      lag = math.min(lag + love.timer.step(), TICK_RATE * MAX_FRAME_SKIP)
    end

    while lag >= TICK_RATE do
      if love.update then love.update(TICK_RATE) end
      lag = lag - TICK_RATE
    end

    if love.graphics and love.graphics.isActive() then
      love.graphics.origin()
      love.graphics.clear(love.graphics.getBackgroundColor())

      if love.draw then
        love.draw()
      end
      love.graphics.present()
    end

    -- Even though we limit tick rate and not frame rate, we might want to cap framerate at 1000 frame rate as mentioned https://love2d.org/forums/viewtopic.php?f=4&t=76998&p=198629&hilit=love.timer.sleep#p160881
    if love.timer then
      love.timer.sleep(0.001)
    end
  end
end