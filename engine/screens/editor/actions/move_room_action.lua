local Class = require 'lib.class'
local lume = require 'lib.lume'

local MoveRoomAction = Class {
  init = function(self, mapData, roomData, oldCoords, newCoords)
    self.mapData = mapData
    self.roomData = roomData
    self.oldCoords = oldCoords
    self.newCoords = newCoords
  end
}

function MoveRoomAction:getType()
  return 'resize_room_action'
end

--[[
  Common Action method implementation
]]
function MoveRoomAction:execute()
  self.mapData:removeRoom(self.roomData)
  self.roomData.topLeftPosX = self.newCoords.topLeftPosX
  self.roomData.topLeftPosY = self.newCoords.topLeftPosY
  self.mapData:addRoom(self.roomData)
end

function MoveRoomAction:undo()
  self.mapData:removeRoom(self.roomData)
  self.roomData.topLeftPosX = self.oldCoords.topLeftPosX
  self.roomData.topLeftPosY = self.oldCoords.topLeftPosY
  self.mapData:addRoom(self.roomData)
end

function MoveRoomAction:isValid()
  return true
end

return MoveRoomAction