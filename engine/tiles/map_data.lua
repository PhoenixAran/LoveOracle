local Class = require 'lib.class'
local lume = require 'lib.lume'
local RoomData = require 'engine.tiles.room_data'
local TileLayer = require 'engine.tiles.layers.tile_layer'

local NIL_TABLE = { }

-- TODO: ObjectLayer
-- Export Type Map Data
local MapData = Class {
  init = function(self, data)
    if not data then 
      data = NIL_TABLE
    end
    self.name = data.name or nil
    self.sizeX = data.sizeX or 16
    self.sizeY = data.sizeY or 16
    self.size = self.sizeX * self.sizeY
    --[[
      Thinking that the default should be this:
      layer 1: tiles
      layer 2: tiles 
      layer 3: entities / objects
    ]]
    self.layerCount = data.layerCount or 3
    
    -- deserialize layers
    local layers = data.layers or { }
    lume.each(data.layers, function(layerData)
      local layerType = layerData.layerType
      if layerType == 'tile_layer' then
        local tileLayer = TileLayer(layerData)
        -- update size just in case
        tileLayer.sizeX = self.sizeX
        tileLayer.sizeY = self.sizeY
      else
        error('Unsupported map layer type: ' .. layerType)
      end
    end)
    self.layers = layers
    
    -- deserialize rooms
    data.rooms = data.rooms or { }
    local rooms = { }
    lume.each(data.rooms, function(roomData)
      lume.push(RoomData(roomData))
    end)
    self.rooms = rooms
  end
}

function MapData:getType()
  return 'map_data'
end

function MapData:getName()
  return self.name
end

function MapData:setName(name)
  self.name = name
end

function MapData:getLayers()
  return self.layers
end

function MapData:setLayers(layers)
  self.layers = layers
end

function MapData:getLayerCount()
  return self.layerCount
end

function MapData:getSize()
  return self.size
end

function MapData:getSizeX()
  return self.sizeX
end

function MapData:getSizeY()
  return self.sizeY
end

function MapData:getSizeXY()
  return self.sizeX, self.sizeY
end

function MapData:resize(x, y)
  --TODO: figure out how to handle existing tile placement and entity placement when resizing map data
end

function MapData:setTile(layerIndex, tileData, x, y)
  if y == nil then
    assert(x <= self.sizeX, 'x is out of bounds')
    self.tiles[x] = tileData
  else
    local index = (x - 1) * self.sizeY + y
    assert(index <= self.size, '(' .. tostring(x) .. ', ' + tostring(y) .. ' is out of bounds')
    self.tiles[(x - 1) * self.sizeY + y] = tileData 
  end
end

function MapData:getTile(layerIndex, x, y)
  assert(1 <= layer and layer <= self.layerCount)
  local tileLayer = self.layers[layerIndex]
  assert(tileLayer:getType() == 'tile_layer', 'layer at index '.. tostring(layerIndex) .. ' is not a tile_layer')
  if y == nil then
    assert(x <= self.size, 'x is out of bounds')
    return tileLayer:getTile(x)
  end
  local index = (x - 1) * self.sizeY + y
  assert(index <= self.size, '( ' .. tostring(x) .. ', ' .. tostring(y) .. ') is out of bounds')
  return tileLayer:getTile(x, y)
end

--TODO: Add/Remove Room Data methods
function MapData:addRoom(room)
  local tlx, tly = room:getTopLeftPosition()
  local brx, bry = room:getBottomRightPosition()
  assert(1 <= tlx and tlx <= self.sizeX, 'room out of bounds')
  assert(1 <= tly and tly <= self.sizeY, 'room out of bounds')
  assert(1 <= brx and brx <= self.sizeX, 'room out of bounds')
  assert(1 <= brx and brx <= self.sizeY, 'room out of bounds')
end

function MapData:removeRoom(room)
  lume.remove(self.rooms, room)
end

function MapData:getSerializableTable()
  serializableLayers = { }
  for _, layer in ipairs(self.layers) do
    lume.push(serializableLayers, layer:getSerializableTable())
  end
  -- TODO: Serialize Rooms
  return {
    name = self:getName(),
    layerCount = self.layerCount,
    layers = serializableLayers,
    sizeX = self:getSizeX(),
    sizeY = self:getSizeY()
  }
end

return MapData