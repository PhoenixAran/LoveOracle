local Class = require 'lib.class'
local lume = require 'lib.lume'
local SignalConnectType = require 'engine.enums.signal_connect_type'

--- Represents a single link between a signal and a listener
---@class SignalConnection
---@field signal Signal
---@field targetObject SignalObject
---@field connectType SignalConnectType
---@field bindingArgs any[]
---@field argumentHolder table
---@field targetMethod string
---@field init function
local SignalConnection = Class {
  init = function(self, signal, targetObject, targetMethod, connectType, bindingArgs)
    self.signal = signal
    self.targetObject = targetObject
    self.targetMethod = targetMethod
    self.connectType = connectType
    self.bindingArgs = bindingArgs or {}
    self.argumentHolder = {} 
  end
}

--- Runs the target method. Merges stored args with call-time args.
---@param ... any
function SignalConnection:emit(...)
  local method = self.targetObject[self.targetMethod]
  assert(method ~= nil, 'Target method ' .. self.targetMethod .. ' does not exist on target object')
  
  local args = lume.concat(self.bindingArgs, {...})
  method(self.targetObject, unpack(args))

  if self.connectType == SignalConnectType.oneShot then
    self:disconnect()
  end
end

--- Tells the parent signal to stop talking to this object.
function SignalConnection:disconnect()
  self.signal:disconnect(self.targetObject, self.signal.name)
end

--- The actual event "channel" held by a SignalObject
---@class Signal
---@field sourceObject SignalObject
---@field name string
---@field connections SignalConnection[]
---@field init function
---@field _emitSnapshot SignalConnection[]
local Signal = Class {
  init = function(self, sourceObject, name)
    self.sourceObject = sourceObject
    self.name = name
    self.connections = {}
    self._emitSnapshot = {}
  end
}

--- Snapshots the listeners and fires them. Mid-loop removals won't break the iterator.
---@param ... any
function Signal:emit(...)
  lume.clear(self._emitSnapshot)
  for i = 1, #self.connections do
    self._emitSnapshot[i] = self.connections[i]
  end

  for i = 1, #self._emitSnapshot do
    local connection = self._emitSnapshot[i]
    
    -- Final check: don't call it if a previous listener killed it earlier this frame
    if lume.find(self.connections, connection) then
      connection:emit(...)
    end
  end

  lume.clear(self._emitSnapshot)
end

--- Creates a connection. ConnectType can be bindArgs if you use the shorthand.
---@param targetObject SignalObject
---@param targetMethod string
---@param connectType SignalConnectType|any[]
---@param bindArgs any[]?
function Signal:connect(targetObject, targetMethod, connectType, bindArgs)
  if type(connectType) == 'table' then
    bindArgs = connectType
    connectType = SignalConnectType.default
  end
  
  local connection = SignalConnection(self, targetObject, targetMethod, connectType, bindArgs)
  table.insert(self.connections, connection)
  table.insert(targetObject.connections, connection)
end

--- Removes a listener from both the signal and the listener's own tracker.
---@param otherObject SignalObject
---@param signalName string
function Signal:disconnect(otherObject, signalName)
  for i = #self.connections, 1, -1 do
    local c = self.connections[i]
    if c.targetObject == otherObject and (not signalName or c.signal.name == signalName) then
      table.remove(self.connections, i)
    end
  end

  for i = #otherObject.connections, 1, -1 do
    local c = otherObject.connections[i]
    if c.signal == self then
      table.remove(otherObject.connections, i)
    end
  end
end

--- Base class for anything that needs to send or receive events
---@class SignalObject
---@field signals table<string, Signal>
---@field connections SignalConnection[] 
---@field init function
local SignalObject = Class {
  init = function(self)
    self.signals = {}
    self.connections = {}
  end
}

--- Register a new signal name on this object.
---@param signalName string
function SignalObject:signal(signalName)
  self.signals[signalName] = Signal(self, signalName)
end

--- Trigger an event by name.
---@param signalName string
---@param ... any
function SignalObject:emit(signalName, ...)
  local sig = self.signals[signalName]
  assert(sig ~= nil, 'Signal ' .. signalName .. ' does not exist')
  sig:emit(...)
end

--- Start listening to a signal on another object.
---@param signalName string
---@param otherObject SignalObject
---@param targetMethod string
---@param bindArgs any[]?
function SignalObject:connect(signalName, otherObject, targetMethod, bindArgs)
  local sig = self.signals[signalName]
  assert(sig ~= nil, 'Signal ' .. signalName .. ' does not exist')
  sig:connect(otherObject, targetMethod, bindArgs)
end

--- Stop listening to a specific signal.
---@param signalName string
---@param otherObject SignalObject
function SignalObject:disconnect(signalName, otherObject)
  local sig = self.signals[signalName]
  if sig then
    sig:disconnect(otherObject, signalName)
  end
end

--- Unsubscribe from every object this instance is currently watching.
function SignalObject:clearConnections()
  while #self.connections > 0 do
      local connection = self.connections[#self.connections]
      if connection then
          connection:disconnect()
      end
      if self.connections[#self.connections] == connection then
          table.remove(self.connections)
      end
  end
end

--- Tear-down function. Use this before nil-ing out an entity so the GC can grab it.
function SignalObject:release()
  self:clearConnections()
  for _, signal in pairs(self.signals) do
      while #signal.connections > 0 do
          local connection = signal.connections[#signal.connections]
          if connection then
              connection:disconnect()
          end
          if signal.connections[#signal.connections] == connection then
              table.remove(signal.connections)
          end
      end
  end
end

--- Standard type getter for debugging/tracking.
---@return string
function SignalObject:getType()
  return 'signal_object'
end

return SignalObject