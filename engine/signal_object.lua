local Class = require 'lib.class'
local lume = require 'lib.lume'

-- friend type SignalConnection
local SignalConnection = Class {
  init = function(self, signal, targetObject, targetMethod, bindingArgs)
    self.signal = signal
    self.targetObject = targetObject
    self.targetMethod = targetMethod
    self.bindingArgs = bindingArgs
    self.argumentHolder = { }
  end
}

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

function SignalConnection:disconnect()
  self.signal:disconnect(self.targetObject, self.targetMethod)
end

-- friend type Signal
local Signal = Class {
  init = function(self, sourceObject, name)
    self.sourceObject = sourceObject
    self.name = name
    self.connections = { }
  end
}

function Signal:emit(...)
  for _, connection in ipairs(self.connections) do
    connection:emit(...)
  end
end

function Signal:connect(targetObject, targetMethod, bindArgs)
  local connection = SignalConnection(self, targetObject, targetMethod, bindArgs)
  self.connections[#self.connections + 1] = connection
  targetObject.connections[#targetObject.connections + 1] = connection
end

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

-- export type SignalObject
local SignalObject = Class {
  init = function(self)
    self.signals = { }
    -- signalconnections that this object exists in
    self.connections = { }
  end
}

function SignalObject:signal(signalName)
  self.signals[signalName] = Signal(self, signalName)
end

function SignalObject:emit(signalName, ...)
  self.signals[signalName]:emit(...)
end

function SignalObject:connect(signalName, otherObject, targetMethod, bindArgs)
  assert(self.signals[signalName] ~= nil, 'Signal ' .. signalName .. ' does not exist')
  self.signals[signalName]:connect(otherObject, targetMethod, bindArgs)
end

function SignalObject:disconnect(signalName, otherObject, targetMethod)
  self.signals[signalName]:disconnect(otherObject, targetMethod)
end

function SignalObject:clearConnections()
  for _, connection in ipairs(self.connections) do
    connection:disconnect()
  end
end

-- call this so this can actually get garbage collected
-- if this isnt called, there is a possibility for dangling references
function SignalObject:free()
  self:clearConnections()
  for k, signal in pairs(self.signals) do
    for _, connection in ipairs(self.signals[k]) do
      connection:disconnect()
    end
  end
end

function SignalObject:getType()
  return 'signal_object'
end

return SignalObject