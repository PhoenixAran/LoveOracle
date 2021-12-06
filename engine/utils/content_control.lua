local AssetManager = require 'engine.utils.asset_manager'
local GameConfig = require 'game_config'
local PaletteBank = require 'engine.utils.palette_bank'
local SpriteBank = require 'engine.utils.sprite_bank'
local TiledMapLoader = require 'engine.tiles.tiled.tiled_map_loader'
local BitTag = require 'engine.utils.bit_tag'
local lume = require 'lib.lume'

--[[
  Module that will take care of loading in assets, setting
  up the banks (palette banks, sprite banks, tileset banks),
  and setting up the BitTag module.
  You can also use this module to unload assets and reload them.
  Useful for Content Viewing / debugging
]]
local ContentControl = { }

-- TODO:make fonts non hardcoded
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
    if love.filesystem.getInfo(path).type == 'directory' then
      loadSpriteSheets(path)
    else
      AssetManager.loadSpriteSheetFile(path)
    end
  end
end

local function initBitTags()
  for k, v in ipairs(GameConfig.physicsFlags) do
    BitTag(v)
  end
end

function ContentControl.buildContent()
  initBitTags()
  loadFonts()
  loadImages('data/assets/images')
  loadSpriteSheets('data/assets/spritesheets')
  PaletteBank.initialize('data.palettes')
  SpriteBank.initialize('data.sprites')
  TiledMapLoader.initializeTilesets()
end

function ContentControl.unloadContent()
  BitTag.reset()
  SpriteBank.unload()
  PaletteBank.unload()
  AssetManager.unload()
end

return ContentControl
