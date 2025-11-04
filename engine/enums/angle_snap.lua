local lume = require 'lib.lume'

---@diagnostic disable: inject-field
---@enum AngleSnap 
local AngleSnap = {
  none = -1,
  to4 = 0,
  to8 = 1,
  to16 = 2,
  to32 = 3,
  to64 = 4
}

local function vector(x, y)
  return { x = x, y = y}
end

local snapVectors = {
  [AngleSnap.to4] = {
    vector(1, 0),    -- right
    vector(0, 1),    -- up
    vector(-1, 0),   -- left
    vector(0, -1)    -- down
  },
  [AngleSnap.to8] = {
    vector(1, 0),    -- right
    vector(1, 1),    -- up-right
    vector(0, 1),    -- up
    vector(-1, 1),   -- up-left
    vector(-1, 0),   -- left
    vector(-1, -1),  -- down-left
    vector(0, -1),   -- down
    vector(1, -1)    -- down-right
  },
  [AngleSnap.to16] = {
    vector(1, 0),                    -- 0°
    vector(1, 0.41421356237),        -- 22.5°
    vector(1, 1),                    -- 45°
    vector(0.41421356237, 1),        -- 67.5°
    vector(0, 1),                    -- 90°
    vector(-0.41421356237, 1),       -- 112.5°
    vector(-1, 1),                   -- 135°
    vector(-1, 0.41421356237),       -- 157.5°
    vector(-1, 0),                   -- 180°
    vector(-1, -0.41421356237),      -- 202.5°
    vector(-1, -1),                  -- 225°
    vector(-0.41421356237, -1),      -- 247.5°
    vector(0, -1),                   -- 270°
    vector(0.41421356237, -1),       -- 292.5°
    vector(1, -1),                   -- 315°
    vector(1, -0.41421356237)        -- 337.5°
  },
  [AngleSnap.to32] = {
    vector(1, 0),                    -- 0°
    vector(1, 0.19891236738),        -- 11.25°
    vector(1, 0.41421356237),        -- 22.5°
    vector(1, 0.66817863792),        -- 33.75°
    vector(1, 1),                    -- 45°
    vector(0.66817863792, 1),        -- 56.25°
    vector(0.41421356237, 1),        -- 67.5°
    vector(0.19891236738, 1),        -- 78.75°
    vector(0, 1),                    -- 90°
    vector(-0.19891236738, 1),       -- 101.25°
    vector(-0.41421356237, 1),       -- 112.5°
    vector(-0.66817863792, 1),       -- 123.75°
    vector(-1, 1),                   -- 135°
    vector(-1, 0.66817863792),       -- 146.25°
    vector(-1, 0.41421356237),       -- 157.5°
    vector(-1, 0.19891236738),       -- 168.75°
    vector(-1, 0),                   -- 180°
    vector(-1, -0.19891236738),      -- 191.25°
    vector(-1, -0.41421356237),      -- 202.5°
    vector(-1, -0.66817863792),      -- 213.75°
    vector(-1, -1),                  -- 225°
    vector(-0.66817863792, -1),      -- 236.25°
    vector(-0.41421356237, -1),      -- 247.5°
    vector(-0.19891236738, -1),      -- 258.75°
    vector(0, -1),                   -- 270°
    vector(0.19891236738, -1),       -- 281.25°
    vector(0.41421356237, -1),       -- 292.5°
    vector(0.66817863792, -1),       -- 303.75°
    vector(1, -1),                   -- 315°
    vector(1, -0.66817863792),       -- 326.25°
    vector(1, -0.41421356237),       -- 337.5°
    vector(1, -0.19891236738)        -- 348.75°
  },
  [AngleSnap.to64] = {
    vector(1, 0),                    -- 0°
    vector(1, 0.09849140336),        -- 5.625°
    vector(1, 0.19891236738),        -- 11.25°
    vector(1, 0.30334668307),        -- 16.875°
    vector(1, 0.41421356237),        -- 22.5°
    vector(1, 0.53451113595),        -- 28.125°
    vector(1, 0.66817863792),        -- 33.75°
    vector(1, 0.82067879083),        -- 39.375°
    vector(1, 1),                    -- 45°
    vector(0.82067879083, 1),        -- 50.625°
    vector(0.66817863792, 1),        -- 56.25°
    vector(0.53451113595, 1),        -- 61.875°
    vector(0.41421356237, 1),        -- 67.5°
    vector(0.30334668307, 1),        -- 73.125°
    vector(0.19891236738, 1),        -- 78.75°
    vector(0.09849140336, 1),        -- 84.375°
    vector(0, 1),                    -- 90°
    vector(-0.09849140336, 1),       -- 95.625°
    vector(-0.19891236738, 1),       -- 101.25°
    vector(-0.30334668307, 1),       -- 106.875°
    vector(-0.41421356237, 1),       -- 112.5°
    vector(-0.53451113595, 1),       -- 118.125°
    vector(-0.66817863792, 1),       -- 123.75°
    vector(-0.82067879083, 1),       -- 129.375°
    vector(-1, 1),                   -- 135°
    vector(-1, 0.82067879083),       -- 140.625°
    vector(-1, 0.66817863792),       -- 146.25°
    vector(-1, 0.53451113595),       -- 151.875°
    vector(-1, 0.41421356237),       -- 157.5°
    vector(-1, 0.30334668307),       -- 163.125°
    vector(-1, 0.19891236738),       -- 168.75°
    vector(-1, 0.09849140336),       -- 174.375°
    vector(-1, 0),                   -- 180°
    vector(-1, -0.09849140336),      -- 185.625°
    vector(-1, -0.19891236738),      -- 191.25°
    vector(-1, -0.30334668307),      -- 196.875°
    vector(-1, -0.41421356237),      -- 202.5°
    vector(-1, -0.53451113595),      -- 208.125°
    vector(-1, -0.66817863792),      -- 213.75°
    vector(-1, -0.82067879083),      -- 219.375°
    vector(-1, -1),                  -- 225°
    vector(-0.82067879083, -1),      -- 230.625°
    vector(-0.66817863792, -1),      -- 236.25°
    vector(-0.53451113595, -1),      -- 241.875°
    vector(-0.41421356237, -1),      -- 247.5°
    vector(-0.30334668307, -1),      -- 253.125°
    vector(-0.19891236738, -1),      -- 258.75°
    vector(-0.09849140336, -1),      -- 264.375°
    vector(0, -1),                   -- 270°
    vector(0.09849140336, -1),       -- 275.625°
    vector(0.19891236738, -1),       -- 281.25°
    vector(0.30334668307, -1),       -- 286.875°
    vector(0.41421356237, -1),       -- 292.5°
    vector(0.53451113595, -1),       -- 298.125°
    vector(0.66817863792, -1),       -- 303.75°
    vector(0.82067879083, -1),       -- 309.375°
    vector(1, -1),                   -- 315°
    vector(1, -0.82067879083),       -- 320.625°
    vector(1, -0.66817863792),       -- 326.25°
    vector(1, -0.53451113595),       -- 331.875°
    vector(1, -0.41421356237),       -- 337.5°
    vector(1, -0.30334668307),       -- 343.125°
    vector(1, -0.19891236738),       -- 348.75°
    vector(1, -0.09849140336)        -- 354.375°
  }
}
-- give 360 degrees via programatic loop
snapVectors[AngleSnap.none] = { }
for i = 0, 359 do
  local angle = (i / 360) * math.pi * 2
  lume.push(snapVectors[AngleSnap.none], vector(math.cos(angle), math.sin(angle)))
end

function AngleSnap.toVector(angleSnap, x, y)
  if x == 0 and y == 0 then
    return x, y
  end
  if angleSnap == AngleSnap.none then
    return x, y
  end
  
  local vectorMap = snapVectors[angleSnap]
  if vectorMap == nil then
    error(tostring(angleSnap) .. ' AngleSnap enum out of range')
  end
  
  -- Use the same logic as original snapDirection function but with lookup table
  local theta = math.atan2(y, x)
  local FULL_ANGLE = math.pi * 2

  if theta < 0 then
    theta = theta + FULL_ANGLE
  end

  local intervalCount = #vectorMap
  local angleSnapInterval = FULL_ANGLE / intervalCount
  local angleIndex = math.floor((theta / angleSnapInterval) + 0.5) % intervalCount

  local length = math.sqrt(x*x + y*y)
  local snappedVec = vectorMap[angleIndex + 1]  -- Lua arrays are 1-indexed

  -- Return normalized snap direction with original length
  return snappedVec.x * length, snappedVec.y * length
end

---@param angleSnap AngleSnap?
---@return function iterator, table table, integer index
function AngleSnap.vectors(angleSnap)
  if angleSnap == nil then
    angleSnap = AngleSnap.none
  end
  return ipairs(snapVectors[angleSnap])
end

---@param angleSnap? AngleSnap
---@return number, number
function AngleSnap.getRandomVector(angleSnap)
  if angleSnap ~= AngleSnap.none and angleSnap ~= nil then
    local randomVector = lume.randomchoice(snapVectors[angleSnap])
    return randomVector.x, randomVector.y
  end
  -- return a random x, y in unit length
  local angle = math.random() * math.pi * 2
  return math.cos(angle), math.sin(angle)
end

-- TODO start using this

return AngleSnap