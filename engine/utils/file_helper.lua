---@diagnostic disable: unused-function
local FileHelper = { }

---@diagnostic disable-next-line: unused-local
local function split(str, inSplitPattern)
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

--gets name of file without path and extension
function FileHelper.getFilePathWithoutExtension(path)
  local newPath = path:match("(.+)%.")
  return newPath
end

function FileHelper.getFileNameWithoutExtension(file)
  local name = file:match("^.+/(.+)$"):match("(.+)%.")
  return name
end

function FileHelper.getFileNameWithoutPath(path)
  local strSplit = split(path, '/')
  return strSplit[#strSplit]
end

return FileHelper