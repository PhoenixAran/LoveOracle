local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local inspect = require 'lib.inspect'
local Slab = require 'lib.slab'
local rect = require 'engine.utils.rectangle'
local AssetManager = require 'engine.utils.asset_manager'
local BaseScreen = require 'engine.screens.base_screen'

local TilesetTheme = require 'engine.tiles.tileset_theme'
local PaletteBank = require 'engine.utils.palette_bank'
local SpriteBank = require 'engine.utils.sprite_bank'
local TilesetBank = require 'engine.utils.tileset_bank'

local MapData = require 'engine.tiles.map_data'
local RoomData = require 'engine.tiles.room_data'

local Camera = require 'lib.camera'

local TILE_MARGIN = 1
local TILE_PADDING = 1
local GRID_SIZE = MapData.GRID_SIZE

local RESIZER_MARGIN = 16
-- Friend Type
local RoomResizeSquare = Class {
  init = function(self, roomData, direction, camera, onResize)
    self.roomData = roomData
    self.direction = direction
    self.camera = camera
    self.onResize = onResize
    self.state = 'none'
    self.x = 0
    self.y = 0
    self.cachedX = 0
    self.cachedY = 0 
    self.minX = 0
    self.minY = 0
    self.maxX = 0
    self.maxY = 0
    self.size = 24
    self.clickMousePosX = 0
    self.clickMousePosY = 0
    -- we want a draw position for the resize square
    -- so we need to subtract 1 from the tilemap indices 
    local rx1, ry1 = roomData:getTopLeftPosition()
    rx1 = rx1 - 1
    ry1 = ry1 - 1
    local rx2, ry2 = roomData:getBottomRightPosition()
    --rx2 = rx2 - 1
    --ry2 = ry2 - 1
    
    rx1, ry1 = vector.mul(GRID_SIZE, rx1, ry1)
    rx2, ry2 = vector.mul(GRID_SIZE, rx2, ry2)
    local rw = roomData:getSizeX() * GRID_SIZE
    local rh = roomData:getSizeY() * GRID_SIZE

    
    if self.direction == 'up' then
      self.x = (rw / 2) + rx1
      self.y = ry1 - RESIZER_MARGIN
      self.maxY = ry2 - (GRID_SIZE * 3) + RESIZER_MARGIN
    elseif self.direction == 'down' then
      self.x = (rw / 2) + rx1
      self.y = ry2  + RESIZER_MARGIN
      self.minY = ry1 + (GRID_SIZE * 3) - RESIZER_MARGIN
    elseif self.direction == 'left' then
      self.x = rx1 - RESIZER_MARGIN
      self.y = (rh / 2) + ry1
      self.maxX = rx2 - (GRID_SIZE * 3) + RESIZER_MARGIN
    elseif self.direction == 'right' then
      self.x = rx2 + RESIZER_MARGIN
      self.y = (rh / 2) + ry1
      self.minX = rx1 + (GRID_SIZE * 3) - RESIZER_MARGIN
    end

  end
}

function RoomResizeSquare:draw()
  if self.state == 'none' then
    love.graphics.setColor(153 / 255, 50 / 255, 204 / 255)
  else
    love.graphics.setColor(100 / 255, 149 / 255, 237 / 255)
  end
  love.graphics.rectangle('fill', self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
  love.graphics.setColor(1, 1, 1)
end

function RoomResizeSquare:update(dt)
  if self.state == 'drag' then
    if not love.mouse.isDown(1) then
      self:resizeRoom()
      self.state = 'none'
      return
    end
    local mx, my = self.camera:getMousePosition()

    if self.direction == 'up' then
      self.y = math.min(self.maxY, self.cachedY - self.clickMousePosY + my)
    elseif self.direction == 'down' then
      self.y = math.max(self.minY, self.cachedY - self.clickMousePosY + my)
    elseif self.direction == 'left' then
      self.x = math.min(self.maxX, self.cachedX - self.clickMousePosX + mx)
    elseif self.direction == 'right' then
      self.x = math.max(self.minX, self.cachedX - self.clickMousePosX + mx)
    end
  else
    local mx, my = self.camera:getMousePosition()
    if love.mouse.isDown(1) and 
    rect.containsPoint(self.x - self.size / 2, self.y - self.size / 2, self.size, self.size, mx, my) then
      self.clickMousePosX = mx
      self.clickMousePosY = my
      self.cachedX = self.x
      self.cachedY = self.y
      self.state = 'drag'
    end
  end
end

function RoomResizeSquare:resizeRoom()
  local x1, y1 = self.roomData:getTopLeftPosition()
  local x2, y2 = self.roomData:getBottomRightPosition()
  if self.direction == 'up' then
    -- change y1
    y1 = math.floor((self.y + RESIZER_MARGIN) / GRID_SIZE) + 1
  elseif self.direction == 'down' then
    -- change y2
    y2 = math.ceil((self.y - RESIZER_MARGIN) / GRID_SIZE)
  elseif self.direction == 'left' then
    -- change x1
    x1 = math.floor((self.x + RESIZER_MARGIN) / GRID_SIZE) + 1
  elseif self.direction == 'right' then
    -- change x2
    x2 = math.ceil((self.x - RESIZER_MARGIN) / GRID_SIZE)
  end
  if self.onResize then
    self.onResize(self.roomData, x1, y1, x2, y2)
  end
end

local RoomMover = Class {
  init = function(self, roomData, camera, onMove)
    self.roomData = roomData
    self.camera = camera
    self.onMove = onMove
    self.state = 'none'
    self.x = 0
    self.y = 0
    self.size = 24
    self.clickMousePosX = 0
    self.clickMousePosY = 0
    self.lastMousePosX = 0
    self.lastMousePosY = 0

    local rx, ry = roomData:getTopLeftPosition()
    rx = (rx - 1) * GRID_SIZE
    ry = (ry - 1) * GRID_SIZE
    local rw = roomData:getSizeX() * GRID_SIZE
    local rh = roomData:getSizeY() * GRID_SIZE

    self.x = rx + (rw / 2)
    self.y = ry + (rh / 2)
  end
}

function RoomMover:moveRoom()
  local rw = self.roomData:getSizeX() * GRID_SIZE
  local rh = self.roomData:getSizeY() * GRID_SIZE

  -- get top left coordinate from room mover's current position
  local x1 = math.floor((self.x - (rw / 2)) / GRID_SIZE) + 1
  local y1 = math.floor((self.y - (rh / 2)) / GRID_SIZE) + 1

  -- get bottom right coordinate from room mover's current position
  local x2 = math.floor((self.x + (rw / 2)) / GRID_SIZE)
  local y2 = math.floor((self.y + (rh / 2)) / GRID_SIZE)
  if self.onMove then
    self.onMove(self.roomData, x1, y1, x2, y2)
  end
end

function RoomMover:update(dt)
  if self.state == 'drag' then
    if not love.mouse.isDown(1) then
      self:moveRoom()
      self.state = 'none'
    else
      local mx, my = self.camera:getMousePosition()
      local dx = self.cachedX -  self.clickMousePosX + mx
      local dy = self.cachedY -  self.clickMousePosY + my

      self.x = dx
      self.y = dy
    end
  else
    local mx, my = self.camera:getMousePosition()
    if love.mouse.isDown(1) and 
    rect.containsPoint(self.x - self.size / 2, self.y - self.size / 2, self.size, self.size, mx, my) then
      self.clickMousePosX = mx
      self.clickMousePosY = my
      self.cachedX = self.x
      self.cachedY = self.y
      self.state = 'drag'
    end
  end
end

function RoomMover:draw()
  if self.state == 'none' then
    love.graphics.setColor(153 / 255, 50 / 255, 204 / 255)
  else
    love.graphics.setColor(100 / 255, 149 / 255, 237 / 255)
  end
  love.graphics.rectangle('fill', self.x - self.size / 2, self.y - self.size / 2, self.size, self.size)
  love.graphics.setColor(1, 1, 1)
end

-- Friend Type
-- Holds RoomResizeSquare instances for each side of the room
-- Also handles the room mover object
local RoomTransformer = Class {
  init = function(self, roomData, camera, onResize, onMove)
    print(onMove)
    self.roomData = roomData
    self.onResize = onResize
    self.roomMover = RoomMover(roomData, camera, onMove)
    self.upR = RoomResizeSquare(roomData, 'up', camera, onResize)
    self.downR = RoomResizeSquare(roomData, 'down', camera, onResize)
    self.leftR = RoomResizeSquare(roomData, 'left', camera, onResize)
    self.rightR = RoomResizeSquare(roomData, 'right', camera, onResize)
    self.resizers = { self.upR, self.downR, self.leftR, self.rightR }
  end
}

-- if room is being resized this frame
-- Called when we want to find out if we want to handle the delete key
-- or pick another room
function RoomTransformer:isActive()
  for _, r in ipairs(self.resizers) do
    if r.state == 'drag' then
      return true
    end
  end
  if self.roomMover.state == 'drag' then
    return true
  end
  return false
end

function RoomTransformer:update(dt)
  local updatedResizer = false
  local updatedMover = false
  for _, r in ipairs(self.resizers) do
    if r.state == 'drag' then
      r:update(dt)
      updatedResizer = true
    end
  end
  if not updatedResizer then
    if self.roomMover.state == 'drag' then
      self.roomMover:update(dt)
      updatedMover = true
    end
  end
  if not updatedResizer and not updatedMover then
    lume.each(self.resizers, 'update', dt)
    self.roomMover:update(dt)
  end
end

function RoomTransformer:draw()
  if self.roomMover.state == 'drag' then
    self.roomMover:draw()
  elseif self.leftR.state == 'drag' or self.rightR.state == 'drag' or self.upR.state == 'drag'
  or self.downR.state == 'drag' then
    self.leftR:draw()
    self.rightR:draw()
    self.upR:draw()
    self.downR:draw() 
  else
    self.roomMover:draw()
    self.leftR:draw()
    self.rightR:draw()
    self.upR:draw()
    self.downR:draw() 
  end

  love.graphics.setColor(1, 1, 204 / 255, 0.20)
  
  local x, y = self.roomData:getTopLeftPosition()
  x = (x - 1) * GRID_SIZE
  y = (y - 1) * GRID_SIZE
  local w = self.roomData:getSizeX() * GRID_SIZE
  local h = self.roomData:getSizeY() * GRID_SIZE
  if self.upR.state == 'drag' then
    y = self.upR.y + RESIZER_MARGIN
    h = self.downR.y - y - RESIZER_MARGIN
  elseif self.downR.state == 'drag' then
    h = self.downR.y - y - RESIZER_MARGIN
  elseif self.leftR.state == 'drag' then
    x = self.leftR.x + RESIZER_MARGIN
    w = self.rightR.x - x - RESIZER_MARGIN
  elseif self.rightR.state == 'drag' then
    w = self.rightR.x - x - RESIZER_MARGIN
  elseif self.roomMover.state == 'drag' then
    x = math.floor((self.roomMover.x - w / 2) / GRID_SIZE) * GRID_SIZE
    y = math.floor((self.roomMover.y - h / 2) / GRID_SIZE) * GRID_SIZE
  end

  love.graphics.setColor(1, 1, 204 / 255, 0.20)
  love.graphics.rectangle('fill', x, y, w, h)
  love.graphics.setColor(0, 0, 0)
  love.graphics.setLineWidth(2)
  love.graphics.rectangle('line', x, y, w, h)
  --love.graphics.rectangle('fill', (rx1 - 1) * GRID_SIZE, (ry1 - 1) * GRID_SIZE, width, height)
  love.graphics.setLineWidth(1)
  love.graphics.setColor(1, 1, 1)
end

-- Enums
local MapEditorState = {
  Edit = 1,
  Play = 2
}

local MapLayer = {
  Background = 1,
  Foreground = 2,
  Object = 3
}

local ControlMode = {
  -- place and erase tiles
  Tile = 1,
  Room = 2,
  PickRoom = 3
}
local ControlModeValues = { 
  'Tile',
  'Room',
  'Pick Room'
}

local RoomControlState = {
  None = 1,
  Creating = 2
}

local LayerViewMode = { 
  Normal = 1,
  FadeOthers = 2,
  HideOthers = 3
}
local LayerViewModeValues =  {"Normal", "Fade Others", 'Hide Others'}

-- Export Type
-- NB: Do not allow hot reloading when in map editor screen
local MapEditor = Class { __include = BaseScreen,
  init = function(self)
    BaseScreen.init(self)
    --[[
      Camera
    ]]
    self.camera = Camera()
    self.cameraZoomLevels = { 0.8, 1, 2, 3, 4, 5, 6, 7, 8 }
    self.cameraZoomIndex = 1
    self.camera.scale = 0.8
    -- mouse position, used to drag camera
    self.previousMousePositionX = 0
    self.previousMousePositionY = 0
    self.currentMousePositionX = 0
    self.currentMousePositionY = 0

    --[[
      Tileset Theme
    ]]
    self.tilesetThemeList = { }
    self.tilesetThemeName = ''
    self.tilesetTheme = nil

    --[[
      Tileset
    ]]
    self.tileset = nil
    self.tilesetList = { }
    self.tilesetCanvas = nil
    self.maxW = nil
    self.maxH = nil
    self.subW = nil
    self.subH = nil
    self.selectedTileIndexX = nil
    self.selectedTileIndexY = nil
    self.hoverTileIndexX = nil
    self.hoverTileIndexY = nil
    self.selectedTileData = nil

    --[[
      Tileset Zoom
    ]]
    self.zoomLevels = { 1, 2, 4, 6, 8, 12}
    self.zoom = 1


    --[[
      File Dialog
    ]]
    self.fileDialog = ''
    self.fileDialogResult = ""

    --[[
      Dialog Boxes
    ]]
    self.showControlListDialog = false

    --[[
      Map Data
    ]]
    -- TODO retrieve map data from disk via deserialization instead of hard coded map data instance
    self.mapData = MapData({
      name = 'test-map',
      sizeX = 48,
      sizeY = 48
    })
    
    --[[
      Editor Control
    ]]
    self.controlModeIndex = 1
    self.controlMode = ControlMode.Tile

    -- view stuff
    self.showGrid = true
    self.layerViewMode = LayerViewMode.Normal

    -- room stuff
    self.roomControlState = RoomControlState.None
    -- grid coordinates for when user starts to create a room
    self.roomStartX = -1
    self.roomStartY = -1
    self.roomEndX = -1
    self.roomEndY = -1
    
    -- room pick stuff
    self.selectedRoom = nil -- room data instance
    -- room resizer widget
    self.roomTransformer = nil

    self.selectedLayerIndex = 1
    self.layerIndexValues = {
      ['Background'] = 1,
      ['Foreground'] = 2,
      ['Object'] = 3
    }
    self.layerIndexValuesInverse = lume.invert(self.layerIndexValues)
    self.showBackgroundLayer = false
    self.showForegroundLayer = false
    self.showObjectLayer = false
    -- room display stuff
    self.showRoomBorders = true
    self.showRoomAreas = false
  end
}

function MapEditor:updateTileset(tilesetThemeName, tilesetName, forceUpdate)
  if forceUpdate == nil then
    forceUpdate = false
  end
  if tilesetThemeName == self.tilesetThemeName and tilesetName == self.tilesetName and not forceUpdate then
    return
  end
  if tilesetThemeName == '' then
    return
  end
  self.tilesetTheme = TilesetBank.getTilesetTheme(tilesetThemeName)
  if tilesetName == '' then
    return
  end

  -- get the width and height of tileset since canvas will most likely be larter
  -- than what is needed for tileset size
  self.tileset = self.tilesetTheme:getTileset(tilesetName)
  self.subW = (self.tileset.tileSize * self.tileset.sizeX) + ((self.tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
  self.subH = (self.tileset.tileSize * self.tileset.sizeY) + ((self.tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)

  -- update
  self.tilesetName = tilesetName
  self.tilesetThemeName = tilesetThemeName
end

function MapEditor:updateHoverTileIndex(x, y)
  if x == nil or y == nil then
    self.hoverTileIndex = nil
    self.hoverTileIndexY = nil
  elseif 1 <= x and x <= self.tileset.sizeX and 1 <= y and y <= self.tileset.sizeY and self.tileset:getTile(x, y) then
    self.hoverTileIndexX = x
    self.hoverTileIndexY = y
  else
    self.hoverTileIndexX = nil
    self.hoverTileIndexY = nil
  end
end

function MapEditor:updateSelectedTileIndex(x, y)
  if x ~= nil and y ~= nil and 1 <= x and x <= self.tileset.sizeX and 1 <= y and y <= self.tileset.sizeY then
    local newTilesetData = self.tileset:getTile(x, y)
    if self.selectedTileData == newTilesetData then
      -- deselect tile if we're clicking it while its selected
      self.selectedTileData = nil
      self.selectedTileIndexX = nil
      self.selectedTileIndexY = nil
    else
      self.selectedTileData = newTilesetData
      self.selectedTileIndexX = x
      self.selectedTileIndexY = y
    end
  end
end

function MapEditor:updateRoomControl()
  assert(self.mapData, 'Attempted to call MapEditor:updateRoomControl but current map data instance is null')
  if love.mouse.isDown(1) and Slab.IsVoidHovered() then
    if self.roomControlState == RoomControlState.None then
      local tx, ty = self:getMouseToMapCoords()
      local inMapBounds = false
      if 1 <= tx and tx <= self.mapData:getSizeX() and
        1 <= ty and ty <= self.mapData:getSizeY() then
          inMapBounds = true
      end
      if not inMapBounds then
        return
      end
      -- init room drag rectangle
      self.roomStartX = tx
      self.roomStartY = ty
      self.roomEndX = tx
      self.roomEndY = ty
      self.roomControlState = RoomControlState.Create
    elseif self.roomControlState == RoomControlState.Create then
      local tx, ty = self:getMouseToMapCoords()
      local inMapBounds = false
      if 1 <= tx and tx <= self.mapData:getSizeX() and
        1 <= ty and ty <= self.mapData:getSizeY() then
          inMapBounds = true
      end
      if inMapBounds then
        self.roomEndX = tx
        self.roomEndY = ty
      end
    end
  else
    if self.roomControlState == RoomControlState.Create then
      -- try to create room if user was previously dragging a room rectangle
      self:action_addRoom()
      self.roomStartX = -1
      self.roomStartY = -1
      self.roomEndX = -1
      self.roomEndY = -1
      self.roomControlState = RoomControlState.None
    end
  end
end

function MapEditor:resetCamera()
  self.camera.x = love.graphics.getWidth() / 2
  self.camera.y = love.graphics.getHeight() / 2
  self.camera.scale = .8
end

function MapEditor:getMouseToMapCoords()
  assert(self.mapData, 'Attempted to call MapEditor:getMouseToMapCoords but current map data instance is null')
  local mouseX, mouseY = self.camera:toWorldCoords(self.currentMousePositionX, self.currentMousePositionY)
  local tx = math.floor(mouseX / MapData.GRID_SIZE) + 1
  local ty = math.floor(mouseY / MapData.GRID_SIZE) + 1
  return tx, ty
end

function MapEditor:drawMapLayer(mapLayer, mapLayerIndex)

  -- TODO: Select tileset theme based off if tile is inside room or not
  local alpha = 1
  if self.layerViewMode == LayerViewMode.HideOthers and self.selectedLayerIndex ~= mapLayerIndex then
    return
  end
  if self.layerViewMode == LayerViewMode.FadeOthers and self.selectedLayerIndex ~= mapLayerIndex then
    alpha = .60
  end
  if mapLayer:getType() == 'tile_layer' then
    local tilesetTheme = TilesetBank.getDefaultTilesetTheme()
    for i = 1, mapLayer.sizeX do
      for j = 1, mapLayer.sizeY do
        local layerTile = mapLayer:getTile(i, j)
        if layerTile ~= nil then
          local tileData = tilesetTheme:getTile(layerTile)
          local tileSprite = tileData:getSprite()
          local sx = (i - 1) * MapData.GRID_SIZE + (MapData.GRID_SIZE / 2)
          local sy = (j - 1) * MapData.GRID_SIZE + (MapData.GRID_SIZE / 2)
          tileSprite:draw(sx, sy, alpha)
        end
      end
    end
  end
  -- TODO: Object Layer
end

--[[
  Map Edit Actions
  TODO: Each function that resides in this section
  should push an action object to the stack so user can undo and redo
]]
function MapEditor:action_placeTile()
  assert(self.selectedTileData, 'Attempted to call MapEditor:action_placeTile but no tile data is selected')
  local tx, ty = self:getMouseToMapCoords()
  if 1 <= tx and tx <= self.mapData:getSizeX() and
    1 <= ty and ty <= self.mapData:getSizeY() then
    local gid = self.tilesetTheme:getTileGid(self.tileset, self.selectedTileData.id)
    self.mapData:setTile(self.selectedLayerIndex, gid, tx, ty)
  end
end

function MapEditor:action_removeTile()
  local tx, ty = self:getMouseToMapCoords()
  if 1 <= tx and tx <= self.mapData:getSizeX() and
    1 <= ty and ty <= self.mapData:getSizeY() then
    self.mapData:setTile(self.selectedLayerIndex, nil, tx, ty)
  end
end

function MapEditor:action_addRoom()
  local tx1, ty1 = 0, 0
  local tx2, ty2 = 0, 0
  if self.roomStartX <= self.roomEndX then
    tx1 = self.roomStartX
    tx2 = self.roomEndX
  else
    tx1 = self.roomEndX
    tx2 = self.roomStartX
  end
  if self.roomStartY <= self.roomEndY then
    ty1 = self.roomStartY
    ty2 = self.roomEndY
  else
    ty1 = self.roomEndY
    ty2 = self.roomStartY
  end
  local overlapsOtherRoom = false
  for _, roomData in ipairs(self.mapData.rooms) do
    local rx1, ry1 = roomData:getTopLeftPosition()
    rx1 = rx1 - 1 
    ry1 = ry1 - 1
    overlapsOtherRoom = rect.intersects(rx1, ry1, roomData:getSizeX(), roomData:getSizeY(),
                                        (tx1 - 1), (ty1 - 1), tx2 - (tx1 - 1), ty2 - (ty1 - 1))
    if overlapsOtherRoom then
      break
    end
  end
  if not overlapsOtherRoom then
    local room = RoomData({
      name = string.format('room_%d-%d_%d-%d', tx1, ty1, tx2, ty2),
      theme = self.tilesetThemeName,
      topLeftPosX = tx1,
      topLeftPosY = ty1,
      sizeX = tx2 - (tx1 - 1),
      sizeY = ty2 - (ty1 - 1)
    })
    self.mapData:addRoom(room)
  end
end

function MapEditor:action_resizeRoom(roomData, x1, y1, x2, y2)
  x1 = math.max(1, x1)
  y1 = math.max(1, y1)
  x2 = math.min(self.mapData.sizeX, x2)
  y2 = math.min(self.mapData.sizeY, y2)
  local overlapsOtherRoom = false
  for _, rd in ipairs(self.mapData.rooms) do
    if rd ~= roomData then
      local rx1, ry1 = rd:getTopLeftPosition()
      rx1 = rx1 - 1 
      ry1 = ry1 - 1
      overlapsOtherRoom = rect.intersects(rx1, ry1, rd:getSizeX(), rd:getSizeY(),
                                          (x1 - 1), (y1 - 1), x2 - (x1 - 1), y2 - (y1 - 1))
      if overlapsOtherRoom then
        break
      end
    end
  end
  if not overlapsOtherRoom then
    self.mapData:removeRoom(roomData)
    roomData.topLeftPosX = x1
    roomData.topLeftPosY = y1
    roomData.sizeX = x2 - (x1 - 1)
    roomData.sizeY = y2 - (y1 - 1)
    self.mapData:addRoom(roomData)
  end
  self.roomTransformer = RoomTransformer(roomData, self.camera, function(a, b, c, d, e)
    self:action_resizeRoom(a, b, c, d, e)
  end, function(a, b, c, d, e) 
    self:action_moveRoom(a, b, c, d, e)
  end)
end

function MapEditor:action_removeRoom()
  self.selectedRoom = nil
  self.mapData:removeRoom(self.RoomTransformer.roomData)
  self.roomTransformer = nil
end

function MapEditor:action_moveRoom(roomData, x1, y1, x2, y2)
  local roomMoved = false
  if 1 <= x1 and x1 <= self.mapData.sizeX and 1 <= y1 and y1 <= self.mapData.sizeY 
  and 1 <= x2 and x2 <= self.mapData.sizeX and 1 <= y2 and y2 <= self.mapData.sizeY  then
    local overlapsOtherRoom = false
    for _, rd in ipairs(self.mapData.rooms) do
      if rd ~= roomData then
        local rx1, ry1 = rd:getTopLeftPosition()
        rx1 = rx1 - 1 
        ry1 = ry1 - 1
        overlapsOtherRoom = rect.intersects(rx1, ry1, rd:getSizeX(), rd:getSizeY(),
                                            (x1 - 1), (y1 - 1), x2 - (x1 - 1), y2 - (y1 - 1))
        if overlapsOtherRoom then
          break
        end
      end
    end
    if not overlapsOtherRoom then
      self.mapData:removeRoom(roomData)
      roomData.topLeftPosX = x1
      roomData.topLeftPosY = y1
      roomData.sizeX = x2 - (x1 - 1)
      roomData.sizeY = y2 - (y1 - 1)
      self.mapData:addRoom(roomData)
    end
  end

  self.roomTransformer = RoomTransformer(roomData, self.camera, function(a, b, c, d, e)
    self:action_resizeRoom(a, b, c, d, e)
  end, function(a, b, c, d, e) 
    self:action_moveRoom(a, b, c, d, e)
  end)
end

--[[ 
  Roomy callbacks
]]
function MapEditor:enter(prev, ...)
  self.tilesetThemeList = { }
  self.tilesetTheme = nil
  local maxW, maxH = 1, 1
  -- find the canvas width and height of largest tileset size
  for _, tileset in pairs(TilesetBank.tilesets) do
    local w = (tileset.tileSize * tileset.sizeX) + ((tileset.sizeX - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    local h = (tileset.tileSize * tileset.sizeY) + ((tileset.sizeY - 1) * TILE_PADDING) + (TILE_MARGIN * 2)
    maxW = math.max(maxW, w)
    maxH = math.max(maxH, h)
  end
  self.tilesetCanvas = love.graphics.newCanvas(maxW, maxH)
  self.tilesetCanvas:setFilter('nearest', 'nearest')

  for k, _ in pairs(TilesetBank.tilesetThemes) do
    -- push keys for the list box
    lume.push(self.tilesetThemeList, k)
  end
  assert(lume.invert(self.tilesetThemeList)['default'], 'No tileset theme with name "default" found')
  self.tilesetThemeName = 'default'
  self.tilesetList = TilesetTheme.getRequiredTilesets()
  self.tileset = nil
  self.tilesetName = self.tilesetList[1] or ''
  self:updateTileset(self.tilesetThemeName, self.tilesetName, true)
end

function MapEditor:update(dt)
  Slab.Update(dt)
  --[[
    MAIN MENU BAR
  ]]
  if Slab.BeginMainMenuBar() then
    if Slab.BeginMenu('File') then
      --TODO: File Explorer
      if Slab.MenuItemChecked('New Map') then
        print('TODO New Map')
      end
      Slab.Separator()
      if Slab.MenuItemChecked('Open Map...') then
        print('TODO Open Map')
      end
      Slab.Separator()
      if Slab.MenuItemChecked('Save') then
        print('TODO Save Map')
      end
      if Slab.MenuItemChecked('Save As') then
        print('TODO Save As')
      end
      Slab.EndMenu()
    end
    if Slab.BeginMenu('Camera') then
      if Slab.MenuItemChecked('Reset Camera') then
        self:resetCamera()
      end
      Slab.EndMenu()
    end
    if Slab.BeginMenu('Help') then
      if Slab.MenuItemChecked('List Controls') then
        self.showControlListDialog = true
      end
      Slab.EndMenu()
    end
    Slab.EndMainMenuBar()
  end
  if self.showControlListDialog then
    local result = Slab.MessageBox("Control List", [[
      Mouse 1 : Places Tile
      Mouse 2 : Removes Tile
      Mouse 3 or M + Mouse Drag : Move Camera
    ]])
    if result ~= "" then
      self.showControlListDialog = false
    end
  end

  --[[
    Tileset Window
  ]]
  Slab.BeginWindow('map-editor-tileset-window', { Title = "Tileset" })
  Slab.Text('Tileset Theme')
  local selectedTilesetThemeName = self.tilesetThemeName
  if Slab.BeginComboBox('map-editor-tileset-theme-combobox', {Selected = selectedTilesetThemeName}) then
    for _, v in ipairs(self.tilesetThemeList) do
      if Slab.TextSelectable(v) then
        selectedTilesetThemeName = v
      end
    end
    Slab.EndComboBox()
  end

  Slab.Text('Tileset')
  local selectedTilesetName = self.tilesetName
  if Slab.BeginComboBox('map-editor-tileset-comboxbox', {Selected = selectedTilesetName}) then
    for _, v in ipairs(self.tilesetList) do
      if Slab.TextSelectable(v) then
        selectedTilesetName = v
      end
    end
    Slab.EndComboBox()
  end

  self:updateTileset(selectedTilesetThemeName, selectedTilesetName)
  Slab.Text('Zoom')
  local selectedZoom = self.zoom
  if Slab.BeginComboBox('map-editor-tileset-zoom-combobox', {Selected = selectedZoom}) then
    for _, v in ipairs(self.zoomLevels) do
      if Slab.TextSelectable(v) then
        selectedZoom = v
      end
    end
    Slab.EndComboBox()
  end
  self.zoom = selectedZoom

  if self.tilesetCanvas then
    -- update hover tile
    local wx, wy = Slab.GetWindowPosition()
    local tilesetImagePosX, tilesetImagePosY = Slab.GetCursorPos({Absolute = true})
    tilesetImagePosX, tilesetImagePosY = vector.sub(tilesetImagePosX, tilesetImagePosY, wx, wy)
    Slab.Image('map-editor-tileset-canvas',
              {
                Image = self.tilesetCanvas,
                WrapH = 'clampzero', WrapV = 'clampzero',
                ScaleX = self.zoom, ScaleY = self.zoom ,
                SubX = 0, SubY = 0, SubW = self.subW, SubH = self.subH
              })
    
    local mx, my = Slab.GetMousePositionWindow()
    mx, my = vector.sub(mx, my, wx, wy)
    local relx, rely = vector.div(self.zoom, vector.sub(mx, my, tilesetImagePosX, tilesetImagePosY))
    relx, rely = math.floor(relx), math.floor(rely)
    -- don't update if the mouse is inbetween the tiles (tile padding or tile margin)
    if relx == TILE_MARGIN or relx % (self.tileset.tileSize + TILE_PADDING) == 0
       or relx == self.tilesetCanvas:getWidth() then
       relx = -100
    end
    if rely == TILE_MARGIN or rely % (self.tileset.tileSize + TILE_PADDING) == 0
      or rely == self.tilesetCanvas:getHeight() then
      rely = -100
    end
    -- the bottom two statements are not a mistake
    -- because we draw a row of tiles alongside the x axis
    local tileIndexY = math.floor(relx / (self.tileset.tileSize + TILE_PADDING)) + 1
    local tileIndexX = math.floor(rely / (self.tileset.tileSize + TILE_PADDING)) + 1
    if Slab.IsMouseClicked(1) and not Slab.IsVoidClicked(1) then
      -- if we select one, display the tile data info
      self:updateSelectedTileIndex(tileIndexX, tileIndexY)
    end
    self:updateHoverTileIndex(tileIndexX, tileIndexY)
  end
  Slab.EndWindow()


  -- Map Editor Control Window stuff
  Slab.BeginWindow('map-editor-control-window', { Title = 'Controls' })
  Slab.Text('Tile Layer')

  if Slab.BeginComboBox('map-layer', { Selected = self.layerIndexValuesInverse[self.selectedLayerIndex] }) then
    for k, v in ipairs(self.layerIndexValuesInverse) do
      if Slab.TextSelectable(v) then
        self.selectedLayerIndex = self.layerIndexValues[v]
      end
    end
    Slab.EndComboBox()
  end
  Slab.Separator()
  Slab.Text('Controls')
  for k, v in ipairs(ControlModeValues) do
    if Slab.RadioButton(v, {Index = k, SelectedIndex = self.controlModeIndex}) then
      self.controlModeIndex = k
    end
  end
  Slab.Separator()
  Slab.Text('Grid')
  if Slab.CheckBox(self.showGrid, "Show Grid") then
    self.showGrid = not self.showGrid
  end
  Slab.Separator()
  Slab.Text('Layer View')
  for k, v in ipairs(LayerViewModeValues) do
    if Slab.RadioButton(v, {Index = k, SelectedIndex = self.layerViewMode}) then
      self.layerViewMode = k
    end
  end
  self.controlMode = self.controlModeIndex
  Slab.Separator()
  Slab.Text('Room View')
  if Slab.CheckBox(self.showRoomBorders, 'Show Room Borders') then
    self.showRoomBorders = not self.showRoomBorders
  end
  if Slab.CheckBox(self.showRoomAreas, 'Show Room Areas') then
    self.showRoomAreas = not self.showRoomAreas
  end
  Slab.EndWindow()

  -- update mouse position
  self.currentMousePositionX, self.currentMousePositionY = love.mouse.getPosition()
  -- update controls
  -- TODO: Turn into a state machine?
  if self.mapData then
    if (love.mouse.isDown(3) or love.keyboard.isDown('m')) and Slab.IsVoidHovered() then
      -- move camera
      local dx = self.previousMousePositionX - self.currentMousePositionX
      local dy = self.previousMousePositionY - self.currentMousePositionY
      self.camera:move(dx, dy)
    elseif self.controlMode == ControlMode.Tile then
      if love.mouse.isDown(1) and self.selectedTileData and Slab.IsVoidHovered() then
        -- place tile
        self:action_placeTile()
      elseif love.mouse.isDown(2) and Slab.IsVoidHovered() then
        -- remove tile
        self:action_removeTile()
      end
    elseif self.controlMode == ControlMode.Room then
      self:updateRoomControl()
    elseif self.controlMode == ControlMode.PickRoom then
      local RoomTransformerInputHandled = false
      if self.selectedRoom then
        assert(self.roomTransformer)
        self.roomTransformer:update(dt)
        RoomTransformerInputHandled = self.roomTransformer:isActive()
      end
      if not RoomTransformerInputHandled then
        if love.mouse.isDown(1) then
          local tx, ty = self:getMouseToMapCoords()
          if 1 <= tx and tx <= self.mapData:getSizeX() and
          1 <= ty and ty <= self.mapData:getSizeY() then
            for _, roomData in ipairs(self.mapData.rooms) do
              local rx1, ry1 = roomData:getTopLeftPosition()
              local rx2, ry2 = roomData:getBottomRightPosition()
              roomPicked = rx1 <= tx and tx <= rx2 and ry1 <= ty and ty <= ry2
              if roomPicked then
                self.selectedRoom = roomData
                local resizeCallback = function(roomData, x1, y1, x2, y2)
                  self:action_resizeRoom(roomData, x1, y1, x2, y2)
                end
                local roomMoveCallback = function(roomData, x1, y1, x2, y2)
                  self:action_moveRoom(roomData, x1, y1, x2, y2)
                end
                self.roomTransformer = RoomTransformer(roomData, self.camera, resizeCallback, roomMoveCallback)
                break
              end
            end
          end
        elseif love.keyboard.isDown('delete') and self.selectedRoom then
          self:action_removeRoom()
        end
      end
    end
  else
    self.camera.x = -love.graphics.getWidth() / 2
    self.camera.y = -love.graphics.getHeight() / 2
  end

  if self.selectedRoom then
    -- make property window for room data
    local slabId = self.selectedRoom:getName() .. '_edit'
    Slab.BeginWindow('RoomInspector', { Title = "Room"})
    Slab.Text('Name')
    if Slab.Input(slabId, { Align = 'left', ReturnOnText = false, Text = self.selectedRoom:getName() }) then
      local uniqueName = true
      local newName = Slab.GetInputText()
      for _, r in ipairs(self.mapData.rooms) do
        if r ~= self.selectedRoom and r.name == newName then
          uniqueName = false
          break
        end
      end
      if uniqueName then
        self.selectedRoom.name = newName
      end
    end
    Slab.Text('Theme')
    
    Slab.EndWindow()
  end
  -- set previous mouse position
  self.previousMousePositionX, self.previousMousePositionY = self.currentMousePositionX, self.currentMousePositionY
end

function MapEditor:draw()
  --[[
    Draw Tilemap (if we're currently editing one)
  ]]
  if self.mapData then
    self.camera:attach()
    love.graphics.setLineWidth(1)
    -- draw clear color for tilemap edit area
    love.graphics.setColor(77 / 255, 77 / 255, 77 / 255)
    love.graphics.rectangle('fill', 0, 0, self.mapData.sizeX * GRID_SIZE, self.mapData.sizeY * GRID_SIZE )
    love.graphics.setColor(1, 1, 1)
    -- draw map layers
    for i, layer in ipairs(self.mapData:getLayers()) do
      self:drawMapLayer(layer, i)
    end
    if self.showGrid then
      -- draw grid
      -- horizontal lines
      for i = 0, self.mapData.sizeX do
        local x1 = 0
        local y1 = i * GRID_SIZE
        local x2 = self.mapData.sizeY * GRID_SIZE
        local y2 = y1
        love.graphics.line(x1, y1, x2, y2)
      end
      -- vertical lines
      for i = 0, self.mapData.sizeX do
        local x1 = i * GRID_SIZE
        local y1 = 0
        local x2 = x1
        local y2 = self.mapData.sizeY * GRID_SIZE
        love.graphics.line(x1, y1, x2, y2)
      end
    end
    
    -- if we have a selected tile, draw a partially transparent version if mouse over grid
    if self.controlMode == ControlMode.Tile and Slab.IsVoidHovered() and self.selectedTileData then
      local tx, ty = self:getMouseToMapCoords()
      if 1 <= tx and tx <= self.mapData:getSizeX() and
        1 <= ty and ty <= self.mapData:getSizeY() then
          local tileSprite = self.selectedTileData:getSprite()
          if tileSprite then
            local sw = tileSprite:getWidth()
            local sh = tileSprite:getHeight()
            local sx = ((tx - 1) * MapData.GRID_SIZE) + MapData.GRID_SIZE / 2
            local sy = ((ty - 1) * MapData.GRID_SIZE) + MapData.GRID_SIZE / 2
            tileSprite:draw(sx, sy, 0.5)
          end
      end
    end

    -- draw room areas
    if self.showRoomAreas or self.controlMode == ControlMode.PickRoom then
      love.graphics.setColor(1, 1, 204 / 255, 0.20)
      for _, roomData in ipairs(self.mapData.rooms) do
        if self.controlMode ~= ControlMode.PickRoom or self.selectedRoom ~= roomData then      
          local rx1, ry1 = roomData:getTopLeftPosition()
          local width = roomData:getSizeX() * GRID_SIZE
          local height = roomData:getSizeY() * GRID_SIZE
          love.graphics.rectangle('fill', (rx1 - 1) * GRID_SIZE, (ry1 - 1) * GRID_SIZE, width, height)
        end
      end
      love.graphics.setColor(1, 1, 1, 0.20)
    end

    -- draw room borders
    if self.showRoomBorders or self.controlMode == ControlMode.PickRoom then
      love.graphics.setColor(0, 0, 0)
      love.graphics.setLineWidth(2)
      for _, roomData in ipairs(self.mapData.rooms) do
        if self.controlMode ~= ControlMode.PickRoom or self.selectedRoom ~= roomData then  
          local rx1, ry1 = roomData:getTopLeftPosition()
          local width = roomData:getSizeX() * GRID_SIZE
          local height = roomData:getSizeY() * GRID_SIZE
          love.graphics.rectangle('line', (rx1 - 1) * GRID_SIZE, (ry1 - 1) * GRID_SIZE, width, height)
        end
      end
      love.graphics.setColor(1, 1, 1)
      love.graphics.setLineWidth(1)
    end 
  
    -- draw selected room
    if self.controlMode == ControlMode.PickRoom and self.selectedRoom then
      assert(self.roomTransformer)
      self.roomTransformer:draw()
    end

    -- draw room creation rectangle
    if self.controlMode == ControlMode.Room and self.roomControlState == RoomControlState.Create then
      -- tile indices for rectangle
      local tx1, ty1 = 0, 0
      local tx2, ty2 = 0, 0
      if self.roomStartX <= self.roomEndX then
        tx1 = self.roomStartX
        tx2 = self.roomEndX
      else
        tx1 = self.roomEndX
        tx2 = self.roomStartX
      end
      if self.roomStartY <= self.roomEndY then
        ty1 = self.roomStartY
        ty2 = self.roomEndY
      else
        ty1 = self.roomEndY
        ty2 = self.roomStartY
      end
    
      -- get draw posititions from tile indices
      --local x1, y1 = vector.mul(MapData.GRID_SIZE, tx1 - 1, ty1 - 1)
      --local x2, y2 = vector.mul(MapData.GRID_SIZE, tx2 - 1, ty2 - 1)
      local x1 = MapData.GRID_SIZE * (tx1 - 1)
      local y1 = MapData.GRID_SIZE * (ty1 - 1)
      local x2 = MapData.GRID_SIZE * (tx2 - 1)
      local y2 = MapData.GRID_SIZE * (ty2 - 1)
      x2 = x2 + self.mapData.GRID_SIZE
      y2 = y2 + self.mapData.GRID_SIZE
      love.graphics.setColor(0, 1, 0, .25)
      love.graphics.rectangle('fill', x1, y1, math.max(x2 - x1, MapData.GRID_SIZE), math.max(y2 - y1, MapData.GRID_SIZE))
      love.graphics.setColor(1, 1, 1)
    end
    self.camera:detach()
  else
    -- no map data file opened
  end

  --[[
    Draw UI
  ]]
  Slab.Draw()
  -- draw tileset on tileset canvas
  love.graphics.setCanvas(self.tilesetCanvas)
  love.graphics.clear()
  local tileSize = self.tileset.tileSize
  for x = 1, self.tileset.sizeX, 1 do
    for y = 1, self.tileset.sizeY, 1 do
      local tilesetData = self.tileset:getTile(x, y)
      if tilesetData then
        local sprite = tilesetData:getSprite()
        -- The bottom two statements are not a mistake, since it
        -- draws the rows along the x axis instead of the y axis
        local posY = ((x - 1) * tileSize) + ((x - 1) * TILE_PADDING) + (TILE_MARGIN)
        local posX = ((y - 1) * tileSize) + ((y - 1) * TILE_PADDING) + (TILE_MARGIN)
        sprite:draw(posX + tileSize / 2, posY + tileSize / 2)
      end
    end
  end
  if self.hoverTileIndexX ~= nil and self.hoverTileIndexY ~= nil then
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line',
      ((self.hoverTileIndexY - 1) * tileSize) + ((self.hoverTileIndexY - 1) * TILE_PADDING) + (TILE_MARGIN),
      ((self.hoverTileIndexX - 1) * tileSize) + ((self.hoverTileIndexX - 1) * TILE_PADDING) + (TILE_MARGIN),
      tileSize,
      tileSize)
  end
  if self.selectedTileData then
    love.graphics.setLineWidth(1)
    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle('line',
      ((self.selectedTileIndexY - 1) * tileSize) + ((self.selectedTileIndexY - 1) * TILE_PADDING) + (TILE_MARGIN),
      ((self.selectedTileIndexX - 1) * tileSize) + ((self.selectedTileIndexX - 1) * TILE_PADDING) + (TILE_MARGIN),
      tileSize,
      tileSize)
  end
  love.graphics.setColor(1, 1, 1)
  love.graphics.setCanvas()
end

-- mouse wheel input
function MapEditor:wheelmoved(x, y)
  if not Slab.IsVoidHovered() then
    return
  end
  if y > 0 then
    -- wheel moved up
    self.cameraZoomIndex = lume.clamp( self.cameraZoomIndex + 1, 1, lume.count(self.cameraZoomLevels))
  elseif y < 0 then 
    -- wheel moved down
    self.cameraZoomIndex = lume.clamp( self.cameraZoomIndex - 1, 1, lume.count(self.cameraZoomLevels))
  end
  self.camera.scale = self.cameraZoomLevels[self.cameraZoomIndex]
end

return MapEditor
