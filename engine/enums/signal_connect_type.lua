---@enum SignalConnectType
local SignalConnectType = {
  --- default connect type. Will be stored until SignelObject:release is called
  default = 0,
  --- one shot connections will disconnect themselves after emission
  oneShot = 1
}

return SignalConnectType