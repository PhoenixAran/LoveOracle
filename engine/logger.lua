-- based off https://github.com/rxi/log.lua
local lume = require 'lib.lume'

-- do NOT use this directly. This should be injected into the love table global as a module
---@class Logger 
---@field useColor boolean
---@field outFile string?
---@field level string
---@field trace function
---@field debug function
---@field info function
---@field warn function
---@field error function
---@field fatal function
local Logger = { 
  useColor = true,
  level = 'trace',
  outFile = nil
}
local MAX_LOG_COUNT = 5000
local logs = { }
local modes = {
  { name = 'trace', color = '\27[34m', },
  { name = 'debug', color = '\27[36m', },
  { name = 'info',  color = '\27[32m', },
  { name = 'warn',  color = '\27[33m', },
  { name = 'error', color = '\27[31m', },
  { name = "fatal", color = '\27[35m', },
}

local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end


local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end

local _tostring = tostring

local tostring = function(...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = round(x, .01)
    end
    t[#t + 1] = _tostring(x)
  end
  return table.concat(t, " ")
end

for i, x in ipairs(modes) do
  local nameupper = x.name:upper()
  Logger[x.name] = function(...)

    -- Return early if we're below the log level
    if i < levels[Logger.level] then
      return
    end

    local msg = tostring(...)
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline

    -- Output to console
    print(string.format("%s[%-6s%s]%s %s: %s",
                        Logger.useColor and x.color or "",
                        nameupper,
                        os.date("%H:%M:%S"),
                        Logger.useColor and "\27[0m" or "",
                        lineinfo,
                        msg))

    -- append to logStr
    local str = string.format("[%-6s%s] %s: %s\n",
                              nameupper, os.date(), lineinfo, msg)

    if lume.count(logs) < MAX_LOG_COUNT then
      lume.push(logs, str)
    else
      logs = { }
      logs[0] = string.format('Log buffer clear. MAX COUNT %s', MAX_LOG_COUNT)
      logs[1] = str
    end
  end
end

function Logger.dump()
  if Logger.outFile then
    local logFilePath = string.format('%s', Logger.outFile)
    local logStr = ''
    for _, v in ipairs(logs) do
      logStr = logStr .. string.format('%s', v)
    end
    love.filesystem.append(logFilePath, logStr)
  end
end


love.log = Logger

-- love error handler
local utf8 = require("utf8")
local function error_printer(msg, layer)
	print((debug.traceback("Error: " .. tostring(msg), 1+(layer or 1)):gsub("\n[^\n]+$", "")))
end
function love.errorhandler(msg)
  Logger.fatal(tostring(msg))
  Logger.dump()

	msg = tostring(msg)

	error_printer(msg, 2)

	if not love.window or not love.graphics or not love.event then
		return
	end

	if not love.graphics.isCreated() or not love.window.isOpen() then
		local success, status = pcall(love.window.setMode, 800, 600)
		if not success or not status then
			return
		end
	end

	-- Reset state.
	if love.mouse then
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
		love.mouse.setRelativeMode(false)
		if love.mouse.isCursorSupported() then
			love.mouse.setCursor()
		end
	end
	if love.joystick then
		-- Stop all joystick vibrations.
		for i,v in ipairs(love.joystick.getJoysticks()) do
			v:setVibration()
		end
	end
	if love.audio then love.audio.stop() end

	love.graphics.reset()
	local font = love.graphics.setNewFont(14)

	love.graphics.setColor(1, 1, 1)

	local trace = debug.traceback()

	love.graphics.origin()

	local sanitizedmsg = {}
	for char in msg:gmatch(utf8.charpattern) do
		table.insert(sanitizedmsg, char)
	end
	sanitizedmsg = table.concat(sanitizedmsg)

	local err = {}

	table.insert(err, "Error\n")
	table.insert(err, sanitizedmsg)

	if #sanitizedmsg ~= #msg then
		table.insert(err, "Invalid UTF-8 string in error message.")
	end

	table.insert(err, "\n")

	for l in trace:gmatch("(.-)\n") do
		if not l:match("boot.lua") then
			l = l:gsub("stack traceback:", "Traceback\n")
			table.insert(err, l)
		end
	end

	local p = table.concat(err, "\n")

	p = p:gsub("\t", "")
	p = p:gsub("%[string \"(.-)\"%]", "%1")

	local function draw()
		if not love.graphics.isActive() then return end
		local pos = 70
		love.graphics.clear(89/255, 157/255, 220/255)
		love.graphics.printf(p, pos, pos, love.graphics.getWidth() - pos)
		love.graphics.present()
	end

	local fullErrorText = p
	local function copyToClipboard()
		if not love.system then return end
		love.system.setClipboardText(fullErrorText)
		p = p .. "\nCopied to clipboard!"
	end

	if love.system then
		p = p .. "\n\nPress Ctrl+C or tap to copy this error"
	end

	return function()
		love.event.pump()

		for e, a, b, c in love.event.poll() do
			if e == "quit" then
				return 1
			elseif e == "keypressed" and a == "escape" then
				return 1
			elseif e == "keypressed" and a == "c" and love.keyboard.isDown("lctrl", "rctrl") then
				copyToClipboard()
			elseif e == "touchpressed" then
				local name = love.window.getTitle()
				if #name == 0 or name == "Untitled" then name = "Game" end
				local buttons = {"OK", "Cancel"}
				if love.system then
					buttons[3] = "Copy to clipboard"
				end
				local pressed = love.window.showMessageBox("Quit "..name.."?", "", buttons)
				if pressed == 1 then
					return 1
				elseif pressed == 3 then
					copyToClipboard()
				end
			end
		end

		draw()

		if love.timer then
			love.timer.sleep(0.1)
		end
	end

end