---@diagnostic disable: missing-fields

-- note: dont have annotations for library object instances
---@class Singletons
---@field input any
---@field screenManager any
---@field gameControl GameControl
---@field roomControl RoomControl
---@field imguiModules any[]
---@field inventory Inventory
---@field joystickData any  -- joystick data, used by lib.gamepadguesser to determine gamepad type for correct button icons
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