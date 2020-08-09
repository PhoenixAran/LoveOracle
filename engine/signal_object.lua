local Class = require 'lib.class'

-- friend type SignalConnection
local SignalConnection = Class {
  init = function(self, signal, targetObject, targetMethod, bindArgs)
    self.signal = signal
    self.targetObject = targetObject
    self.targetMethod = targetMethod
    self.bindingArgs = bindArgs
  end
}

function SignalConnection:emit(...)
  if self.bindingArgs ~= nil and #self.bindingArgs > 1 then
    self.targetObject[self.targetMethod](unpack(self.bindingArgs), ...)
  else
    self.targetObject[self.targetMethod](...)
  end
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

return SignalObject