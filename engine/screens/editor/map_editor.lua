local Class = require 'lib.class'
local lume = require 'lib.lume'
local vector = require 'lib.vector'
local inspect = require 'lib.inspect'
local Slab = require 'lib.slab'
local SignalObject = require 'engine.signal_object'
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

local RoomTransformer = require 'engine.screens.editor.widgets.room_transformer'

local MapEditorActionQueue = require 'engine.screens.editor.actions.map_editor_action_queue'
local PlaceTileAction = require 'engine.screens.editor.actions.place_tile_action'
local RemoveTileAction = require 'engine.screens.editor.actions.remove_tile_action'
local ResizeRoomAction = require 'engine.screens.editor.actions.resize_room_action'
local MoveRoomAction = require 'engine.screens.editor.actions.move_room_action'

local TILE_MARGIN = 1
local TILE_PADDING = 1
local GRID_SIZE = MapData.GRID_SIZE


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
local MapEditor = Class { __include = {BaseScreen, SignalObject},
  init = function(self)
    SignalObject.init(self)
    BaseScreen.init(self)

    self.actionQueue = MapEditorActionQueue(self.mapData)

    --[[
      Mouse
    ]]
    self.mouseStates = { }
    for i = 1, 3 do
      lume.push(self.mouseStates, {
        canUpdate = true,
        isDown = false
      })
    end


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
    self.queuedTileAction = nil

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
    self.roomTransformer = RoomTransformer(self.camera)
    self.roomTransformer:connect('roomMove', self, 'action_moveRoom')
    self.roomTransformer:connect('roomResize', self, 'action_resizeRoom')

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

  -- get the width and height of tileset since canvas will be larger than what is needed for tileset size
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
  if self:isVoidMouseDown(1) and Slab.IsVoidHovered() then
    if self.roomControlState == RoomControlState.None then
      local tx, ty = self:getMouseToMapCoords()
      if self.mapData:indexInBounds(tx, ty) then
        -- init room drag rectangle
        self.roomStartX = tx
        self.roomStartY = ty
        self.roomEndX = tx
        self.roomEndY = ty
        self.roomControlState = RoomControlState.Create
      end
    elseif self.roomControlState == RoomControlState.Create then
      local tx, ty = self:getMouseToMapCoords()
      if self.mapData:indexInBounds(tx, ty) then
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
  local tilesetTheme = TilesetBank.getDefaultTilesetTheme()
  local alpha = 1
  if self.layerViewMode == LayerViewMode.HideOthers and self.selectedLayerIndex ~= mapLayerIndex then
    return
  end
  if self.layerViewMode == LayerViewMode.FadeOthers and self.selectedLayerIndex ~= mapLayerIndex then
    alpha = 0.60
  end
  if mapLayer:getType() == 'tile_layer' then
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

function MapEditor:drawRoomTiles(room)
  if room.theme == 'default' then
    return
  end
  -- draw clear color over default theme tiles that were previously drawn
  love.graphics.setColor(77 / 255, 77 / 255, 77 / 255)
  love.graphics.rectangle('fill', (room.topLeftPosX - 1) * GRID_SIZE, (room.topLeftPosY - 1) * GRID_SIZE, room.sizeX * GRID_SIZE, room.sizeY * GRID_SIZE )
  love.graphics.setColor(1, 1, 1)
  for k, mapLayer in ipairs(self.mapData.layers) do
    local alpha = 1
    local shouldDrawTiles = true
    if self.layerViewMode == LayerViewMode.HideOthers and self.selectedLayerIndex ~= k then
      shouldDrawTiles = false
    end
    if self.layerViewMode == LayerViewMode.FadeOthers and self.selectedLayerIndex ~= k then
      alpha = 0.60
    end
    if shouldDrawTiles then
      if mapLayer:getType() == 'tile_layer' then
        local tilesetTheme = TilesetBank.getTilesetTheme(room.theme)
        for i = room.topLeftPosX, room:getBottomRightPositionX() do
          for j = room.topLeftPosY, room:getBottomRightPositionY() do
            local layerTile = mapLayer:getTile(i, j)
            if layerTile ~= nil then
              local tileData = tilesetTheme:getTile(layerTile)
              local tileSprite = tileData:getSprite()
              local sx = (i - 1) * GRID_SIZE + (GRID_SIZE / 2)
              local sy = (j - 1) * GRID_SIZE + (GRID_SIZE / 2)
              tileSprite:draw(sx, sy, alpha)
            end
          end
        end
      end
    end
  end
end

function MapEditor:updateMouseInput()
  local voidHovered = Slab.IsVoidHovered()
  for i = 1, 3 do
    local mouseState = self.mouseStates[i]
    if Slab.IsMouseClicked(i) then
      mouseState.canUpdate = Slab.IsVoidHovered()
    end
    mouseState.isDown = mouseState.canUpdate and Slab.IsMouseDown(i) and Slab.IsVoidHovered()
  end
end

function MapEditor:isVoidMouseDown(index)
  return self.mouseStates[index] and self.mouseStates[index].isDown
end

--[[
  Map Edit Actions
  TODO: Each function that resides in this section
  should push an action object to the stack so user can undo and redo
]]
function MapEditor:action_placeTile()
  assert(self.selectedTileData, 'Attempted to call MapEditor:action_placeTile but no tile data is selected')
  local gid = self.tilesetTheme:getTileGid(self.tileset, self.selectedTileData.id)
  if not self.queuedTileAction then
    self.queuedTileAction = PlaceTileAction(self.mapData, self.selectedLayerIndex, gid)
  end
  local tx, ty = self:getMouseToMapCoords()
  if self.mapData:indexInBounds(tx, ty) then
    local oldTileId = self.mapData:getTile(self.selectedLayerIndex, tx, ty)
    if oldTileId ~= gid then
      self.queuedTileAction:recordOldTile(tx, ty, self.mapData:getTile(self.selectedLayerIndex, tx, ty))
      self.mapData:setTile(self.selectedLayerIndex, gid, tx, ty)
    end
  end
end

function MapEditor:action_removeTile()
  if not self.queuedTileAction then
    self.queuedTileAction = RemoveTileAction(self.mapData, self.selectedLayerIndex)
  end
  local tx, ty = self:getMouseToMapCoords()
  if self.mapData:indexInBounds(tx, ty) then
    local oldTileId = self.mapData:getTile(self.selectedLayerIndex, tx, ty)
    if oldTileId ~= nil then
      self.mapData:setTile(self.selectedLayerIndex, nil, tx, ty)
    end
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
      name = self.mapData:generateRoomId(),
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
    local oldCoords = {
      topLeftPosX = roomData.topLeftPosX,
      topLeftPosY = roomData.topLeftPosY,
      sizeX = roomData.sizeX,
      sizeY = roomData.sizeY
    }
    local newCoords = {
      topLeftPosX = x1,
      topLeftPosY = y1,
      sizeX = x2 - (x1 - 1),
      sizeY = y2 - (y1 - 1)
    }
    roomData.topLeftPosX = newCoords.topLeftPosX
    roomData.topLeftPosY = newCoords.topLeftPosY
    roomData.sizeX = newCoords.sizeX
    roomData.sizeY = newCoords.sizeY
    self.mapData:addRoom(roomData)
    local action = ResizeRoomAction(self.mapData, roomData, oldCoords, newCoords)
    self.actionQueue:addAction(action)
  end
end

function MapEditor:action_removeRoom()
  self.selectedRoom = nil
  self.mapData:removeRoom(self.roomTransformer.roomData)
  self.roomTransformer = nil
end

function MapEditor:action_moveRoom(roomData, x1, y1, x2, y2)
  local roomMoved = false
  if self.mapData:indexInBounds(x1, y1) and self.mapData:indexInBounds(x2, y2) then
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
      local oldCoords = {
        topLeftPosX = roomData.topLeftPosX,
        topLeftPosY = roomData.topLeftPosY
      }
      local newCoords = {
        topLeftPosX = x1,
        topLeftPosY = y1,
      }
      roomData.topLeftPosX = x1
      roomData.topLeftPosY = y1
      roomData.sizeX = x2 - (x1 - 1)
      roomData.sizeY = y2 - (y1 - 1)
      self.mapData:addRoom(roomData)
      local action = MoveRoomAction(self.mapData, roomData, oldCoords, newCoords)
      self.actionQueue:addAction(action)
    end
  end
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

  self:updateMouseInput()
  
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
    if (self:isVoidMouseDown(3) or love.keyboard.isDown('m')) and Slab.IsVoidHovered() then
      -- move camera
      local dx = self.previousMousePositionX - self.currentMousePositionX
      local dy = self.previousMousePositionY - self.currentMousePositionY
      self.camera:move(dx, dy) 
    elseif self.controlMode == ControlMode.Tile then
      if self:isVoidMouseDown(1) and self.selectedTileData and Slab.IsVoidHovered() then
        -- place tile
        self:action_placeTile()
      elseif self.queuedTileAction and self.queuedTileAction:getType() == 'place_tile_action' then
        self.actionQueue:addAction(self.queuedTileAction)
        self.queuedTileAction = nil
      end
      if not self:isVoidMouseDown(1) and self:isVoidMouseDown(2) and Slab.IsVoidHovered() then
        -- remove tile
        self:action_removeTile()
      elseif self.queuedTileAction and self.queuedTileAction:getType() == 'remove_tile_action' then
        self.actionQueue:addAction(self.queuedTileAction)
        self.queuedTileAction = nil
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
        if self:isVoidMouseDown(1) then
          local tx, ty = self:getMouseToMapCoords()
          if self.mapData:indexInBounds(tx, ty) then
            for _, roomData in ipairs(self.mapData.rooms) do
              local rx1, ry1 = roomData:getTopLeftPosition()
              local rx2, ry2 = roomData:getBottomRightPosition()
              roomPicked = rx1 <= tx and tx <= rx2 and ry1 <= ty and ty <= ry2
              if roomPicked then
                self.selectedRoom = roomData
                self.roomTransformer:setRoomData(roomData)
                break
              end
            end
          end
        elseif love.keyboard.isDown('delete') and self.selectedRoom then
          self:action_removeRoom()
        end
      end
    end
    if love.keyboard.isDown('lctrl') or love.keyboard.isDown('rctrl') then
      if Slab.IsKeyPressed('z') then
        self.actionQueue:undo()
      elseif Slab.IsKeyPressed 'y' then
        self.actionQueue:redo()
      end
    end
  else
    self.camera.x = -love.graphics.getWidth() / 2
    self.camera.y = -love.graphics.getHeight() / 2
  end

  -- This will be used to edit Room OR Object properties
  Slab.BeginWindow('Property Window', { Title = "Property Window"})
  if self.selectedRoom then
    -- make property window for room data
    Slab.Text('Name')
    if Slab.Input('room-name', { Align = 'left', ReturnOnText = false, Text = self.selectedRoom:getName() }) then
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
    Slab.Text('Tileset Theme')
    if Slab.BeginComboBox('room-tileset-theme', {Selected = self.selectedRoom.theme}) then
      for _, v in ipairs(self.tilesetThemeList) do
        if Slab.TextSelectable(v) then
          self.selectedRoom.theme = v
        end
      end
      Slab.EndComboBox()
    end
  else
    Slab.Text('No room or object currently selected')
  end
  Slab.EndWindow()
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

    -- redraw tiles for rooms if they have a tileset other than default
    for i, room in ipairs(self.mapData.rooms) do
      self:drawRoomTiles(room)
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
      if self.mapData:indexInBounds(tx, ty) then
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
    
      -- get draw positions from tile indices
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