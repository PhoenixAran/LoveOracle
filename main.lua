local monocle = require 'lib.monocle'
local gameConfig = require 'game_config'

-- asset loading methods
local function loadFonts()
  assetManager.getFont('fonts/monogram.ttf', 16)
  assetManager.getFont('fonts/dialogue.ttf', 10)
end

local function loadImages(directory)
  directory = directory or 'images'
  local imageFiles = love.filesystem.getDirectoryItems(assetManager.directory .. directory)
  for _, file in ipairs(imageFiles) do
    local path = directory .. '/' .. file
    if love.filesystem.getInfo(assetManager.directory .. path).type == 'directory' then
      loadImages(path)
    else
      assetManager.getImage(path)
    end
  end
end

local function loadSpriteSheets(directory)
  directory = directory or 'spritesheets'
  local spritesheetFiles = love.filesystem.getDirectoryItems(assetManager.directory .. directory)
  for _, file in ipairs(spritesheetFiles) do
    local path = directory .. '/' .. file
    -- assetManager combines base asset path for us so we need to manually combine path to get correct 
    -- path for love.filesystem.getinfo
    if love.filesystem.getInfo(assetManager.directory .. path).type == 'directory' then
      loadSpriteSheets(path)
    else
      assetManager.loadSpriteSheetFile(path)
    end
  end
end

local function drawFPSAndMemory()  
  local monogram = assetManager.getFont('fonts/monogram.ttf')
  love.graphics.setFont(monogram)
  local fps = ("fps:%d, %d kbs"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

local function drawFPS()  
  local monogram = assetManager.getFont('fonts/monogram.ttf')  love.graphics.setFont(monogram)
  local fps = ("fps:%d"):format(love.timer.getFPS())
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

-- alot of globals are declared here
function love.load()
  assetManager = require 'engine.utils.asset_manager'
  assetManager.setDirectory('data/assets/')
  loadFonts() 
  loadImages() 
  loadSpriteSheets()
  
  -- after we load images and spritesheet initialize the sprite bank
  spriteBank = require 'engine.utils.sprite_bank'
  -- use dot notation since its really just calling a bunch of requires
  spriteBank.initialize('data/builders')  

  screenManager = require('lib.roomy').new()
  physics = require 'engine.physics.physics'
  camera = require('lib.camera')(0,0,160, 144)
  tablePool = require 'engine.utils.table_pool'
  tablePool.warmCache(200)
  input = require('lib.baton').new(gameConfig.controls)
  love.window.setTitle(gameConfig.window.title)
  monocle.setup(gameConfig.window.getMonocleArguments())
  love.graphics.setFont(assetManager.getFont('fonts/monogram.ttf'))
  screenManager:hook({ exclude = {'update','draw', 'resize', 'load'} })
  screenManager:enter( require(gameConfig.startupScreen) ())
end

function love.update(dt)
  input:update(dt)
  screenManager:emit('update', dt)
end

function love.draw()
  monocle.begin()
  -- manually call draw in current screen
  screenManager:emit('draw')
  drawFPSAndMemory()
  monocle.finish()
end

function love.resize(w, h)
  monocle.resize(w, h)
  screenManager:emit('resize', w, h)
end