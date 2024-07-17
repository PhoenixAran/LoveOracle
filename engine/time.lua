local MAX_DT = 3+38

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