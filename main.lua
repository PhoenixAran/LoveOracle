local lume = require 'lib.lume'
local gameConfig = require 'game_config'
local ContentControl = require 'engine.content_control'
local AssetManager = require 'engine.asset_manager'
local tick = require 'lib.tick'
local DisplayHandler = require 'engine.display_handler'
love.inspect = require 'lib.inspect'
local _, imgui = pcall(require, 'imgui')

if type(imgui) == 'string' then
  imgui = nil
end

-- singletons
local Singletons = require 'engine.singletons'

-- logger
require 'engine.logger'
-- windows doesnt support color out of the box
love.log.useColor = love.system.getOS() ~= 'Windows'
love.log.outFile = string.format('love-oracle_%s_log.txt', os.date('%Y-%m-%d'))


-- time
require 'engine.time'

-- init quake console
require 'lib.console'
require 'engine.console_commands'

love.log.trace('Game Init')
love.log.debug('Ziggy Engine ' .. gameConfig.version)
print('   |\\|\\')
print('  ..    \\       .')
print('o--     \\\\    / @)')
print(' v__///\\\\\\\\__/ @')
print('   {           }')
print('    {  } \\\\\\{  }')
print('    <_|      <_|')

print()

love.log.debug("OS: " .. love.system.getOS())
love.log.debug(('Renderer: %s %s\nVendor: %s\nGPU: %s'):format(love.graphics.getRendererInfo()))
love.log.debug('Save Directory: ' .. love.filesystem.getSaveDirectory())

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

  -- set up tick rate
  tick.rate = 1 / 60
  tick.framerate = 60
  local _, _, windowFlags = love.window.getMode()
  if windowFlags.refreshrate then
    love.log.debug(('Matching display refresh rate: %d'):format(windowFlags.refreshrate))
    tick.framerate = math.max(tick.framerate, windowFlags.refreshrate)
  end

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
  
  -- build content here (need it for font)
  ContentControl.buildContent()
  love.graphics.setFont(AssetManager.getFont('base_screen_debug'))

  --[[
    Singleton Inits
  ]]
  -- set up screen manager
  screenManager = require('lib.roomy').new()
  -- events we will handle ourselves
  local excludeEvents = { 'update', 'draw', 'resize', 'load' }
  if imgui then
    -- we need to pass events to imgui (so handle everything)
    excludeEvents = lume.concat(excludeEvents, {'textinput', 'keypressed', 'keyreleased', 'mousemoved', 'mousepressed', 'mousereleased', 'wheelmoved'})
  end
  screenManager:hook({ exclude = excludeEvents })
  Singletons.screenManager = screenManager

  -- set up input
  input = require('lib.baton').new(gameConfig.controls)
  Singletons.input = input


  -- set up console
  love.keyboard.setKeyRepeat(true)
  --console.font = AssetManager.getFont('debugConsole')

  love.log.debug(string.format('Launch args: %s', love.inspect(args)))

  -- setup startup screen
  love.log.trace('Startup Screen: ' .. gameConfig.startupScreen)
  screenManager:enter(require(gameConfig.startupScreen)(), unpack(args))
end

function love.update(dt)
  love.time.update(dt)
  screenManager:emit('update', dt)
end

---@diagnostic disable-next-line: duplicate-set-field
function love.draw()
  screenManager:emit('draw')
  -- draw any imgui modules to support debugging/cheat menus
  if imgui and lume.any(Singletons.imguiModules) then
    imgui.NewFrame()
    for _, module in ipairs(Singletons.imguiModules) do
      module:draw()
    end
    imgui.Render()
  end
end

function love.resize(w, h)
  screenManager:emit('resize', w, h)
  DisplayHandler.resize(w, h)
end

function love.quit()
  if imgui then
    imgui.ShutDown()
  end
  love.log.trace('Game Closed')
end

-- imgui stuff
if imgui then
  function love.textinput(t)
    imgui.TextInput(t)
    if not imgui.GetWantCaptureKeyboard() then
      screenManager:emit('textinput', t)
    end
  end

  function love.keypressed(key)
    imgui.KeyPressed(key)
    if not imgui.GetWantCaptureKeyboard() then
      screenManager:emit('keypressed', key)
    end
  end

  function love.keyreleased(key)
    imgui.KeyReleased(key)
    if not imgui.GetWantCaptureKeyboard() then
      screenManager:emit('keyreleased', key)
    end
  end

  function love.mousemoved(x, y)
    imgui.MouseMoved(x, y)
    if not imgui.GetWantCaptureMouse() then
      screenManager:emit('mousemoved', x, y)
    end
  end

  function love.mousepressed(x, y, button)
    imgui.MousePressed(button)
    if not imgui.GetWantCaptureMouse() then
      screenManager:emit('mousepressed', x, y, button)
    end
  end

  function love.mousereleased(x, y, button)
    imgui.MouseReleased(button)
    if not imgui.GetWantCaptureMouse() then
      screenManager:emit('mousereleased', x, y, button)
    end
  end

  function love.wheelmoved(x, y)
    imgui.WheelMoved(y)
    if not imgui.GetWantCaptureMouse() then
      screenManager:emit('wheelmoved', x, y)
    end
  end
end