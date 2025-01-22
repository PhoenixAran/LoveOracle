local imgui = require 'imgui'

local ImguiDemo = { }
local isWindowShowing = true

local function close()
  local singleton = require 'engine.singletons'
  local lume = require 'lib.lume'
  lume.remove(singleton.imguiModules, ImguiDemo)
  isWindowShowing = false
end

function ImguiDemo.setup()
  isWindowShowing = true
end

function ImguiDemo.draw()
  if isWindowShowing then
    isWindowShowing = imgui.ShowDemoWindow(true)
  else
    close()
  end
end

return ImguiDemo