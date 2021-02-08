local Monocle = require 'lib.monocle'
local gameConfig = require 'game_config'
local ContentControl = require 'engine.control.content_control'
local AssetManager = require 'engine.utils.asset_manager'
local Slab = require 'lib.slab'


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
  screenManager:enter( require(gameConfig.startupScreen) ())
  
  Slab.SetINIStatePath(nil)
  Slab.Initialize()
end

function love.update(dt)
  input:update(dt)
  screenManager:emit('update', dt)
end

function love.draw()
  screenManager:emit('draw')
end

function love.resize(w, h)
  monocle:resize(w, h)
  screenManager:emit('resize', w, h)
end