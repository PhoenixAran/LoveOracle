local Singletons = require 'engine.singletons'
local GamepadGuesser = require 'lib.gamepadguesser'

-- TODO have Platform.update() so it can update the current gamepad type
-- and support hot plugging, and changing icons if user uses a keyboard or their controller dynamically

--- helper class for platform specific logic
---@class Platform
Platform = {}

function Platform.getGamepadType()
  local gamepadType = 'pc'

  local joysticks = love.joystick.getJoysticks()
  local firstJoystick = joysticks[1]
  if firstJoystick then
    -- only support one joystick
    -- TODO might be better to have the console value directly in Singletons like Singletons.console
    -- so for eventual ports it can just be set via game_config
    -- then if its 'PC' we can use gamepad guesser, otherwise we can just set it to the correct console value for that platform and skip gamepad guesser entirely
    if Singletons.joystickData then
      Singletons.joystickData:addJoystick(firstJoystick)
      gamepadType = Singletons.joystickData.joysticks[firstJoystick]
    else
      gamepadType = GamepadGuesser.joystickToConsole(firstJoystick)
    end

    if not (gamepadType == 'nintendo' or gamepadType == 'xbox' or gamepadType == 'playstation') then
      gamepadType = 'xbox' -- default to xbox button prompts if we can't identify the controller type
    end
  end

  return gamepadType
end

return Platform