local Class = require 'lib.class'
local lume = require 'lib.lume'

--- FriendType signal connection
---@class SignalConnection
---@field signal Signal
---@field targetObject SignalObject
---@field bindingArgs table
---@field argumentHolder table
---@field targetMethod string
---@field init function
local SignalConnection = Class {
  init = function(self, signal, targetObject, targetMethod, bindingArgs)
    self.signal = signal
    self.targetObject = targetObject
    self.targetMethod = targetMethod
    self.bindingArgs = bindingArgs
    self.argumentHolder = { }
  end
}

--- Emits signal to listener
---@param ... any
function SignalConnection:emit(...)
  if self.bindingArgs ~= nil and #self.bindingArgs > 0 then
    for i, v in ipairs(self.bindingArgs) do
      self.argumentHolder[#self.argumentHolder + 1] = v
    end
  end
  lume.push(self.argumentHolder, ...)
  self.targetObject[self.targetMethod](self.targetObject, unpack(self.argumentHolder))
  lume.clear(self.argumentHolder)
end

--- Disconnect signal from listener
function SignalConnection:disconnect()
  self.signal:disconnect(self.targetObject, self.targetMethod)
end

--- Signal instance
---@class Signal
---@field sourceObject SignalObject
---@field name string
---@field connections SignalConnection[]
local Signal = Class {
  init = function(self, sourceObject, name)
    self.sourceObject = sourceObject
    self.name = name
    self.connections = { }
  end
}

--- Emit signal to listeners
---@param ... any
function Signal:emit(...)
  for _, connection in ipairs(self.connections) do
    connection:emit(...)
  end
end

--- Connect object to signal
---@param targetObject SignalObject
---@param targetMethod string
---@param bindArgs any[]?
function Signal:connect(targetObject, targetMethod, bindArgs)
  local connection = SignalConnection(self, targetObject, targetMethod, bindArgs)
  self.connections[#self.connections + 1] = connection
  targetObject.connections[#targetObject.connections + 1] = connection
end

--- Disconnect object from signal
---@param otherObject SignalObject
---@param targetMethod string
function Signal:disconnect(otherObject, targetMethod)
  for i, connection in ipairs(self.connections) do
    if connection.targetObject == otherObject and targetMethod == connection.targetMethod then
      table.remove(self.connections, i)
      break
    end
  end
  for i, connection in ipairs(otherObject.connections) do
    if connection.targetMethod == targetMethod then
      table.remove(otherObject.connections, i)
      break
    end
  end
end

--- Export Type SignalObject
---@class SignalObject
---@field signals Signal[]
---@field connections SignalConnection[] SignalConnections this SignalObject exists in
---@field init function We get this from the class module
local SignalObject = Class {
  init = function(self)
    self.signals = { }
    self.connections = { }
  end
}

---Create Signal
---@param signalName string
function SignalObject:signal(signalName)
  self.signals[signalName] = Signal(self, signalName)
end

---Emits signal to listeners
---@param signalName string
---@param ... any
function SignalObject:emit(signalName, ...)
  self.signals[signalName]:emit(...)
end

---Connect to specified signal
---@param signalName string
---@param otherObject SignalObject
---@param targetMethod string
---@param bindArgs any[]?
function SignalObject:connect(signalName, otherObject, targetMethod, bindArgs)
  assert(self.signals[signalName] ~= nil, 'Signal ' .. signalName .. ' does not exist')
  self.signals[signalName]:connect(otherObject, targetMethod, bindArgs)
end

---Disconnect from specified signal
---@param signalName string
---@param otherObject SignalObject
---@param targetMethod string
function SignalObject:disconnect(signalName, otherObject, targetMethod)
  self.signals[signalName]:disconnect(otherObject, targetMethod)
end

---Clears all connections this SingalObject is connected to
function SignalObject:clearConnections()
  for _, connection in ipairs(self.connections) do
    connection:disconnect()
  end
end

--- Call this so this can actually get garbage collected
--- if this isnt called, there is a possibility for dangling references
function SignalObject:release()
  self:clearConnections()
  for k, signal in pairs(self.signals) do
    for _, connection in ipairs(self.signals[k]) do
      connection:disconnect()
    end
  end
end

---
---@return string type Type of object this is
function SignalObject:getType()
  return 'signal_object'
end

return SignalObject