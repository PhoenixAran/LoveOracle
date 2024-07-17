local MAX_DT = 3+38

---Not to be confused with love.timer
---@class Time
---@field dt number delta time
---@field unscaledDt number unscaled delta time
---@field timeScale number
local Time = { 
  dt = 0,
  unscaledDt = 0,
  timeScale = 1
}

function Time.update(dt)
  if Time.dt > MAX_DT then
    dt = MAX_DT
  end

  Time.dt = dt * Time.timeScale
  Time.unscaledDt = dt
end

love.time = Time

return Time