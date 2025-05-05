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
    return
  end

  imgui.Text('Lua: ' .. (collectgarbage('count') / 1024) .. ' MB')

  local stats = love.graphics.getStats()
  imgui.Text('VRAM: ' .. (stats.texturememory / (1024 * 1024)) .. ' MB')


  imgui.End()
end

return MemoryInspector