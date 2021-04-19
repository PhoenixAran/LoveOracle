local Class = require 'lib.class'
local lume = require 'lib.lume'

local RemoveRoomAction = Class {
  init = function(self, mapData, roomData)
    self.mapData = mapData
    self.roomData = roomData
  end
}

function RemoveRoomAction:getType()
  return 'add_room_action'
end

--[[
  Common Action method implementation
]]
function RemoveRoomAction:execute()
  self.mapData:removeRoom(self.roomData)
end

function RemoveRoomAction:undo()
  self.mapData:addRoom(self.roomData)
end

function RemoveRoomAction:isValid()
  return true
end

return RemoveRoomAction