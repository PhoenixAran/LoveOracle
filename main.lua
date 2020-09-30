local monocle = require 'lib.monocle'
local cargo = require 'lib.cargo'
local gameConfig = require 'game_config'
local SpriteSheet = require 'engine.graphics.sprite_sheet'

local function drawFPSAndMemory()  
  love.graphics.setFont(monogram)
  local fps = ("fps:%d, %d kbs"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

local function drawFPS()
  love.graphics.setFont(monogram)
  local fps = ("fps:%d"):format(love.timer.getFPS())
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

--gets name of file without path and extension
local function getFileName(file)
  local name = file:match("^.+/(.+)$"):match("(.+)%.")
  return name
end

local function split(str, inSplitPattern)
  local outResults = { }
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( str, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( str, theStart ) )
  return outResults
end

-- create spritesheets from spritesheet file and cache them into the 
-- global spriteSheets table, and into assets.spritesheets
local function parseSpriteSheet(filePath)
  assets.spritesheets = assets.spritesheets or { }
  for line in love.filesystem.lines(filePath) do
    if line then line = line:gsub('%$s+', '') end
    if not (line == nil or line == '' or line:sub(1, 1) == '#') then
      local args = split(line, ',')
      local key = args[1]
      spriteSheets[key] = SpriteSheet(images[key], tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), tonumber(args[5]))
      assets.spritesheets[key] = spriteSheets[key]
    end
  end
end

-- assumes spritesheets directory is just a flat directory
local function loadSpriteSheets(dir)
  local spriteSheetFiles = love.filesystem.getDirectoryItems(dir)
  for _, file in ipairs(spriteSheetFiles) do
    parseSpriteSheet(dir .. '/' .. file)
  end
end

-- alot of globals are declared here
function love.load()
  -- can access images and spritesheets simply by string name, instead of manually through cargo
  images = {} 
  spriteSheets = { }
  assets = cargo.init({
    dir = 'data/assets',
    processors = {
      ['images/'] = function(image, filename)
        image:setFilter('nearest', 'nearest')
        local imageKey = getFileName(filename)
        images[imageKey] = image
      end
    }
  })


  -- preload images
  assets.images(true)
  
  -- load spritesheets
  loadSpriteSheets('data/assets/spritesheets')
  
  -- after we load images and spritesheet initialize the sprite bank
  spriteBank = require 'engine.utils.sprite_bank'
  -- use dot notation since its really just calling a bunch of requires
  spriteBank.initialize('data.builders')
  
  -- fonts
  monogram = assets.fonts.monogram(16)
  monogram:setFilter('nearest', 'nearest')
  dialogue = assets.fonts.dialogue(10)
  dialogue:setFilter('nearest', 'nearest')

  screenManager = require('lib.roomy').new()
  physics = require 'engine.physics.physics'
  camera = require('lib.camera')(0,0,160, 144)
  tablePool = require 'engine.utils.table_pool'
  tablePool.warmCache(200)
  input = require('lib.baton').new(gameConfig.controls)
  love.window.setTitle(gameConfig.window.title)
  monocle.setup(gameConfig.window.getMonocleArguments())
  love.graphics.setFont(monogram)
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