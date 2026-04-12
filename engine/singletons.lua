---@diagnostic disable: missing-fields

-- note: dont have annotations for library object instances
---@class Singletons
---@field input any
---@field screenManager any
---@field gameControl GameControl
---@field roomControl RoomControl
---@field imguiModules any[]
---@field joystickData any
local singletons = {
  input = nil,
  screenManager = { },
  gameControl = { },
  roomControl = { },
  imguiModules = { },
  joystickData = nil
}

function singletons.getType()
  return 'singletons'
end

return singletons