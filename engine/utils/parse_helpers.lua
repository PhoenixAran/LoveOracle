-- Parse Helpers Module

local function split(str, inSplitPattern, array)
  local outResults = { }
  local theStart = 1
  local theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  while theSplitStart do
    table.insert( outResults, string.sub( str, theStart, theSplitStart-1 ) )
    theStart = theSplitEnd + 1
    theSplitStart, theSplitEnd = string.find( str, inSplitPattern, theStart )
  end
  table.insert( outResults, string.sub( str, theStart ) )
  return outResults
end

local function trim(str)
  return (str:gsub("^%s*(.-)%s*$", "%1"))
end

local function argIsString(arg)
  if arg == nil then return false end
  arg = trim(arg)
  return string.len(arg) >= 2 and arg:sub(1, 1) == '"' and arg:sub(-1) == '"'
end

local function argIsNumber(arg)
  if arg == nil then return false end
  return tonumber(arg) ~= nil
end

local function argIsInteger(arg)
  return arg:match("^%-?%d+$")
end

local function parseStringArg(arg)
  -- strip the quotation marks aroudn string
  arg = trim(arg)
  return string.sub(arg, 2, string.len(arg) - 1)
end

return {
  split = split,
  trim = trim,
  argIsString = argIsString,
  argIsNumber = argIsNumber,
  argIsInteger = argIsInteger,
  parseStringArg = parseStringArg
}