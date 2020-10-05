local FileHelper = { }

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

return FileHelper