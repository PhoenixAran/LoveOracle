local monocle = require 'lib.monocle'
local cargo = require 'lib.cargo'
local SpriteSheet = require 'engine.graphics.sprite_sheet'

local function drawFpsAndMemory()  
  local fps = ("fps:%d, %d kbs"):format(love.timer.getFPS(), collectgarbage("count"))
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(fps, 0, 132, 200, 'left')
end

--gets name of file without path and extension
local function getFileName(file)
  local name = file:match("^.+/(.+)$"):match("(.+)%.")
  return name
end

local function split(str, inSplitPattern)
  if not outResults then
    outResults = { }
  end
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
    local args = split(line, ',')
    assert(#args == 2 or #args == 5, 'invalid spritesheet argument line: ' .. tostring(line) .. '\n Argument count: ' .. tostring(#args))
    local key = args[1]
    assert(images[key], 'No image with key ' .. key .. ' exists despite being declared in ' .. filePath .. 'spritesheet file')
    spriteSheets[key] = SpriteSheet(images[key], tonumber(args[2]), tonumber(args[3]), tonumber(args[4]), tonumber(args[5]))
    assets.spritesheets[key] = spriteSheets[key]
  end
end

-- assumes spritesheets directory is just a flat directory
local function loadSpriteSheets(dir)
  local spriteSheetFiles = love.filesystem.getDirectoryItems(dir)
  for _, file in ipairs(spriteSheetFiles) do
    parseSpriteSheet(dir .. '/' .. file)
  end
end

function love.load()
  -- can access images and spritesheets simply by string name, instead of manually through cargo
  images = {} 
  spriteSheets = { }
  assets = cargo.init({
    dir = 'assets',
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
  loadSpriteSheets('assets/spritesheets')
  
  screenManager = require('lib.roomy').new()
  bumpWorld = require('lib.bump').newWorld(32)
  camera = require('lib.camera')(0,0,160, 144)
  input = require('lib.baton').new(require('controls'))

  monocle.setup(160, 144, 160 * 4, 144 * 4)
  font = assets.fonts.monogram(16)
  font:setFilter("nearest", "nearest")
  love.graphics.setFont(font)
  
  screenManager:hook({ exclude = {'update','draw', 'resize'}})
  screenManager:enter( require 'engine.test_screens.composite_sprite_test' ())
end

function love.update(dt)
  input:update(dt)
  screenManager:emit('update', dt)
end

function love.draw()
  monocle.begin()
  -- manually call draw in current screen
  screenManager:emit('draw')
  --drawFpsAndMemory()
  monocle.finish()
end

function love.resize(w, h)
  monocle.resize(w, h)
  screenManager:emit('resize', w, h)
end