local Class = require 'lib.class'
local lume = require 'lib.lume'

local ResizeRoomAction = Class {
  init = function(self, mapData, layerIndex, roomData, oldCoords, newCoords)
    self.mapData = mapData
    self.layerIndex = layerIndex
    self.roomData = roomData
    self.oldCoords = oldCoords
    self.newCoords = newCoords
  end
}

function ResizeRoomAction:getType()
  return 'resize_room_action'
end

--[[
  Common Action method implementation
]]

function ResizeRoomAction:undo()
  self.mapData:removeRoom(self.roomData)
  self.roomData.topLeftPosX = self.oldCoords.topLeftPosX
  self.roomData.topLeftPosY = self.oldCoords.topLeftPosY
  self.roomData.sizeX = self.oldCoords.sizeX
  self.roomData.sizeY = self.oldCoords.sizeY
  self.mapData:addRoom(self.roomData)
end

function ResizeRoomAction:redo()
  self.mapData:removeRoom(self.roomData)
  roomData.topLeftPosX = self.newCoords.topLeftPosX
  roomData.topLeftPosY = self.newCoords.topLeftPosY
  roomData.sizeX = self.newCoords.sizeX
  roomData.sizeY = self.newCoords.sizeY
  self.mapData:addRoom(self.roomData)
end

function ResizeRoomAction:isValid()
  return true
end

return ResizeRoomAction