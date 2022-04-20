local utf8 = require("utf8")

local console = {}

-- configuration
console.key = "f8"
console.revealDuration = 0.4
console.font = nil -- nil -> use current font
console.backgroundColor = {0, 0, 0, 180/255}
console.textColor = {1, 1, 1, 1}
console.maxLines = 100
console.drawLines = 30
console.maxHistory = 20
console.scrollNotice = true

-- actual state
console.height = 0
console.active = false
console.buffer = {}
console.nextBufferIndex = 1
console.scroll = 1 -- the index of the line first drawn in the view
console.input = ""
console.cursor = 0 -- the number of characters before the cursor
console.takenBy = nil
console.promptedBy = nil
console.history = {}

local function len_utf8(text)
    return utf8.len(text)
end

local function sub_utf8(text, from, to)
    return text:sub(utf8.offset(text, from), to and utf8.offset(text, to+1)-1 or text:len())
end

function console.update(dt)
    local deltaHeight = 1 / console.revealDuration * dt
    if console.active then
        console.height = console.height + deltaHeight
        console.height = math.min(console.height, 1)
    else
        console.height = console.height - deltaHeight
        console.height = math.max(console.height, 0)
    end

    if console.takenBy and console.takenBy.update then
        console.takenBy.update(dt)
    end
end

function console.draw()
    local lg = love.graphics
    local winW, winH = lg.getDimensions()
    local font = console.font or lg.getFont()
    local fontH = font:getHeight()

    local margin = 5
    local inputHeight = fontH + margin * 2
    local height = (fontH * console.drawLines + margin * 2 + inputHeight) * console.height
    local inputY = height - inputHeight

    local scissorBackup = {lg.getScissor()}

    lg.setScissor(0, 0, winW, height)
    lg.setColor(console.backgroundColor)
    lg.rectangle("fill", 0, 0, winW, height)
    lg.setColor(console.textColor)
    lg.rectangle("line", 0, 0, winW, height)

    if console.takenBy then
        lg.setScissor(0, 0, winW, math.max(0, height))
        lg.print(console.takenBy.text, margin, margin)
    else
        lg.setScissor(0, 0, winW, math.max(0, height - inputHeight))
        local index = #console.buffer >= console.maxLines and console.nextBufferIndex or 1
        local offset = console.scroll - 1
        for i = 1, #console.buffer do
            lg.print(console.buffer[index], margin, (i-1 - offset)*fontH + margin)
            index = index + 1
            if index > #console.buffer then
                index = 1
            end
        end

        if console.scrollNotice then
            local text = "Press alt+up/down to scroll"
            lg.print(text, winW - font:getWidth(text) - margin, margin)
        end

        lg.setScissor(unpack(scissorBackup))

        if inputY > 0 then
            lg.setColor(console.textColor)
            lg.line(0, inputY, winW, inputY)
            lg.print(console.input, margin, inputY + margin)

            local preCursorText = sub_utf8(console.input, 1, console.cursor)
            local textLen = font:getWidth(preCursorText)
            local cursorX = margin + textLen
            if math.cos(love.timer.getTime() * 2.0 * math.pi) > 0.0 then
                lg.line(cursorX, inputY + margin, cursorX, inputY + margin + fontH)
            end
        end
    end
		love.graphics.setScissor()
end

function console.takeOver(handler)
    if handler then
        if not handler.text or not handler.keypressed then
            error("console.takeOver handler must have .text and .keypressed attribute!")
        end
        if handler.enter then
            handler.enter()
        end
    end
    console.takenBy = handler
end

function console.prompt(str, handler)
    console.print(str)
    console.promptedBy = handler
end

function console.exec(str)
    if console.promptedBy then
        console.promptedBy(str)
        console.promptedBy = nil
    else
        local cmd, args = str:match("(%w+)(.*)")
        if console.commands[cmd] then
            console.commands[cmd](args)
        else
            console.print(("Unknown command: '%s'"):format(cmd))
        end
    end
end

function console.printStr(str)
    local scroll = console.scroll == #console.buffer - console.drawLines + 1

    for s in str:gmatch("[^\r\n]+") do
        console.buffer[console.nextBufferIndex] = s
        console.nextBufferIndex = console.nextBufferIndex + 1
        if console.nextBufferIndex > console.maxLines then
            console.nextBufferIndex = 1
        end
    end

    if scroll then
        console.scroll = #console.buffer - console.drawLines + 1
    end
end

function console.print(...)
    for i = 1, select("#", ...) do
        console.printStr(tostring(select(i, ...)))
    end
end

local function paste(text, selectionFrom, selectionTo)
    local from, to = selectionFrom or console.cursor, selectionTo or console.cursor
    console.input = sub_utf8(console.input, 1, from) .. text .. sub_utf8(console.input, to + 1)
    console.cursor = from + len_utf8(text)
end

local function isalphanum(c)
    -- TODO: Make this match more than only the ASCII-alphanums
    -- utf-8/ascii: digits, capital alphas, small alphas
    return (c >= 48 and c <= 57) or (c >= 65 and c <= 90) or (c >= 97 and c < 122)
end

local function cursorAlphaNum(offset)
    return isalphanum(utf8.codepoint(console.input, console.cursor + (offset or 0)))
end

local function skipWord(backwards)
    local len = len_utf8(console.input)
    if len == 0 then
        return
    end

    local dir = backwards and -1 or 1
    local start = cursorAlphaNum(backwards and 0 or 1)
    while console.cursor >= 0 and console.cursor <= len do
        if cursorAlphaNum() ~= start then break end
        console.cursor = console.cursor + dir
    end
end

function console.keypressed(key)
    local alt = love.keyboard.isDown("lalt") or love.keyboard.isDown("ralt")
    local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

    if key == console.key then
        console.active = not console.active
    end

    if console.takenBy then
        console.takenBy.keypressed(key)
        return
    end
		if not console.active then return end
    if alt and key == "up" then
        console.scroll = math.max(1, console.scroll - 1)
    elseif alt and key == "down" then
        if #console.buffer > console.drawLines then
            console.scroll = math.min(#console.buffer - console.drawLines + 1, console.scroll + 1)
        else
            console.scroll = 1
        end
    elseif key == "up" then
        if console.historyPointer == 0 then
            console.history[0] = console.input
        end
        console.historyPointer = math.min(#console.history, console.historyPointer + 1)
        console.input = console.history[console.historyPointer]
        console.cursor = len_utf8(console.input)
    elseif key == "down" then
        console.historyPointer = math.max(0, console.historyPointer - 1)
        console.input = console.history[console.historyPointer] or console.input
        console.cursor = len_utf8(console.input)
    end

    if key == "return" then
        console.print(">>> " .. console.input)
        local input = console.input
        console.input = ""
        console.cursor = 0
        console.exec(input)
        table.insert(console.history, 1, input)
        while #console.history > console.maxHistory do
            table.remove(console.history)
        end
        console.historyPointer = 0
    end

    -- text input stuff
    if key == "home" then
        console.cursor = 0
    end

    if key == "end" then
        console.cursor = len_utf8(console.input)
    end

    if key == "left" then
        if ctrl then
            skipWord(true)
        else
            console.cursor = math.max(0, console.cursor - 1)
        end
    end

    if key == "right" then
        if ctrl then
            skipWord()
        else
            console.cursor = math.min(len_utf8(console.input), console.cursor + 1)
        end
    end

    if key == "backspace" then
        local to = console.cursor
        if ctrl then
            skipWord(true)
        else
            console.cursor = math.max(0, console.cursor - 1)
        end
        paste("", nil, to)
    end

    if ctrl and key == "v" then
        paste(love.system.getClipboardText())
    end
end

function console.textinput(str)
    if console.active and not console.takenBy then
        paste(str)
    end
end

-- builtin commands
console.commands = {}
console.help = {}

local function trim(s)
  return s:match "^%s*(.-)%s*$"
end

console.help.echo = {"Print a string", section = "Built-In"}
function console.commands.echo(args)
    console.print(trim(args))
end

console.help.clear = {"Clear the console", section="Built-In"}
function console.commands.clear()
    console.buffer = {}
    console.nextBufferIndex = 1
    console.scroll = 1
end

--console.env = setmetatable({}, {__index = console.commands}) -- this does not work!
console.env = {
    ["print"] = console.print,
}

console.help.lua = {"Execute lua code", section = "Built-In"}
function console.commands.lua(args)
    local cmd = trim(args)
    local chunk, err = loadstring(cmd)
    if not chunk then
        print("ls", err)
        console.print("Error!: " .. err)
        return
    end

    setfenv(chunk, console.env)

    local success, arg = pcall(chunk)
    if success then
        local ret = arg
        if ret then
            console.print(tostring(ret))
        end
    else
        local msg = arg
        print("call", msg)
        console.print("Error!: " .. msg)
    end
end

console.help.help = {"Show help", "Use 'help <command>' to show extended help", section="Built-In"}
function console.commands.help(args)
    local cmd = trim(args)
    if console.commands[cmd] then
        local help = console.help[cmd]
        if help then
            console.print("(" .. help.section .. ")")
            console.print(help[1])
            if help[2] then
                console.print(" \n")
                console.print(help[2])
            end
        else
            console.print("No help available")
        end
    else
        if cmd:len() > 0 then
            console.print(("Unknown command '%s'!"):format(cmd))
        end
        local sections = {}
        for command, _ in pairs(console.commands) do
            local section = console.help[command] and console.help[command].section or "Other"
            sections[section] = sections[section] or {}
            table.insert(sections[section], command)
        end

        for sectionName, section in pairs(sections) do
            console.print(sectionName .. ":")
            for _, command in ipairs(section) do
                local text = "    " .. command
                if console.help[command] then
                    text = text .. " - " .. console.help[command][1]
                end
                console.print(text)
            end
            console.print(" \n")
        end
    end
end

-- helper functions

local function strMul(str, f)
    local ret = ""
    for i = 1, f do
        ret = ret .. str
    end
    return ret
end

function console.buttonText(options, offset, width)
    local indent = strMul(" ", offset or 2)
    local lines = {indent, indent, indent, indent, indent, indent, indent}
    for _, option in ipairs(options) do
        local w = width or option.width or 16
        local textOffset = math.max(0, math.floor((w - option.text:len() - 2) / 2))
        local textFiller = w - textOffset - option.text:len() - 2
        local sel = option.selected and "+" or " "

        -- not very efficient at all
        local textLine = strMul(" ", textOffset) .. option.text .. strMul(" ", textFiller)
        lines[1] = lines[1]               .. strMul(sel, w + 2)
        lines[2] = lines[2] .. sel .. "+" .. strMul("-", w - 2) .. "+" .. sel
        lines[3] = lines[3] .. sel .. "|" .. strMul(" ", w - 2) .. "|" .. sel
        lines[4] = lines[4] .. sel .. "|" .. textLine           .. "|" .. sel
        lines[5] = lines[5] .. sel .. "|" .. strMul(" ", w - 2) .. "|" .. sel
        lines[6] = lines[6] .. sel .. "+" .. strMul("-", w - 2) .. "+" .. sel
        lines[7] = lines[7]               .. strMul(sel, w + 2)

        for i = 1, #lines do
            lines[i] = lines[i] .. strMul(" ", 5)
        end
    end
    return table.concat(lines, "\n")
end

local optChooseHandler = {text = ""}

function optChooseHandler.enter()
    optChooseHandler.current = 1
    optChooseHandler.setText()
end

function optChooseHandler.setText()
    local options = {}
    for i, option in ipairs(optChooseHandler.options) do
        table.insert(options, {text = option, selected = i == optChooseHandler.current})
    end
    optChooseHandler.text = " \n \n    " ..
        optChooseHandler.title .. "\n\n" .. console.buttonText(options)
end

function optChooseHandler.keypressed(key)
    if key == "left" then
        optChooseHandler.current = optChooseHandler.current - 1
        if optChooseHandler.current < 1 then
            optChooseHandler.current = #optChooseHandler.options
        end
        optChooseHandler.setText()
    elseif key == "right" then
        optChooseHandler.current = optChooseHandler.current + 1
        if optChooseHandler.current > #optChooseHandler.options then
            optChooseHandler.current = 1
        end
        optChooseHandler.setText()
    end

    if key == "return" then
        optChooseHandler.callback(optChooseHandler.current,
            optChooseHandler.options[optChooseHandler.current])
        console.takeOver()
    end
end

function console.chooseOption(title, options, func)
    optChooseHandler.options = options
    optChooseHandler.callback = func
    optChooseHandler.title = title
    console.takeOver(optChooseHandler)
end

return console