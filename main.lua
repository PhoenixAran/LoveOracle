local Monocle = require 'lib.monocle'
local gameConfig = require 'game_config'
local AssetManager = require 'engine.utils.asset_manager'

-- asset loading methods
local function loadFonts()
  AssetManager.loadFont('data/assets/fonts/monogram.ttf', 16)
  AssetManager.loadFont('data/assets/fonts/dialogue.ttf', 10)
end

local function loadImages(directory)
  local imageFiles = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(imageFiles) do
    local path = directory .. '/' .. file
    if love.filesystem.getInfo(path).type == 'directory' then
      loadImages(path)
    else
      AssetManager.loadImage(path)
    end
  end
end

local function loadSpriteSheets(directory)
  local spritesheetFiles = love.filesystem.getDirectoryItems(directory)
  for _, file in ipairs(spritesheetFiles) do
    local path = directory .. '/' .. file
    -- assetManager combines base asset path for us so we need to manually combine path to get correct 
    -- path for love.filesystem.getinfo
    if love.filesystem.getInfo(path).type == 'directory' then
      loadSpriteSheets(path)
    else
      AssetManager.loadSpriteSheetFile(path)
    end
  end
end

local function initBitTags()
  local BitTag = require 'engine.utils.bit_tag'
  for k, v in ipairs(gameConfig.physicsFlags) do
    BitTag(v)
  end
end

function love.load(arg)  
  -- enable zerobrane studio debugging
  if gameConfig.zbStudioDebug then
    if arg[#arg] == '-debug' then require('mobdebug').start() end
  end
  
  initBitTags()
  
  loadFonts() 
  loadImages('data/assets/images') 
  loadSpriteSheets('data/assets/spritesheets')
  
  -- init palettes
  local paletteBank = require 'engine.utils.palette_bank'
  paletteBank.initialize('data.palettes')
  
  -- after we load images and spritesheet initialize the sprite bank
  local spriteBank = require 'engine.utils.sprite_bank'
  spriteBank.initialize('data.sprites')  
  
  local tablePool = require 'engine.utils.table_pool'
  tablePool.warmCache(64)
  
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