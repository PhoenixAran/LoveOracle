local Class = require 'lib.class'
local lume = require 'lib.lume'

local AddRoomAction = Class {
  init = function(self, mapData, roomData)
    self.mapData = mapData
    self.roomData = roomData
  end
}

function AddRoomAction:getType()
  return 'add_room_action'
end

--[[
  Common Action method implementation
]]
function AddRoomAction:execute()
  self.mapData:addRoom(self.roomData)
end

function AddRoomAction:undo()
  self.mapData:removeRoom(self.roomData)
end

function AddRoomAction:isValid()
  return true
end

return AddRoomAction