local imgui = require 'imgui'


local MemoryInspector = { }
local isWindowOpen = true

local function close()
  local singleton = require 'engine.singletons'
  local lume = require 'lib.lume'
  lume.remove(singleton.imguiModules, MemoryInspector)
end

function MemoryInspector.setup()
  isWindowOpen = true
end

function MemoryInspector.draw()
  isWindowOpen = imgui.Begin('Memory Inspector', true, "ImGuiWindowFlags_MenuBar")
  if not isWindowOpen then
    imgui.End()
    close()
  end
  imgui.Text('Memory ' .. collectgarbage('count') .. ' KB')
  imgui.End()
end

return MemoryInspector