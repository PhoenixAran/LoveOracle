local Class = require 'lib.class'
local SignalObject = require 'engine.signal_object'
local Singletons = require 'engine.singletons'
local input = Singletons.input
local A = Class { __includes = SignalObject,
  init = function(self)
    SignalObject.init(self)
    self:signal('APressed')
  end
}

local B = Class { __includes = SignalObject,
  init = function(self)
    SignalObject.init(self)
  end
}

function B:_onAPressed(bindArg, arg1, arg2)
  print('B:_onAPressed')
  print(bindArg)
  print(arg1)
  print(arg2)
end

local SignalTest = Class {
  init = function(self)
    self.disconnected = false
  end
}

function SignalTest:enter(prev, ...)
  self.a = A()
  self.b = B()
  
  self.a:connect('APressed', self.b, '_onAPressed', { 'bindArg' })
end

function SignalTest:update(dt)
  input:update(dt)
  if input:pressed('left') then
    print('a:emit()')
    self.a:emit('APressed', 'arg1', 'arg2', 'arg3')
  end
  if not self.disconnected and input:pressed('down') then
    print('a:disconnect()')
    self.a:disconnect('APressed', self.b, '_onAPressed')
    self.disconnected = true
  end
  if not self.disconnected and input:pressed('right') then
    print('b:clearConnections')
    self.b:release()
    self.disconnected = true
  end
  if self.disconnected and input:pressed('up') then
    print('a:connect()')
    -- one shot test
    self.a:connect('APressed', self.b, '_onAPressed', 1, { 'bindArg' })
    self.disconnected = false
  end
end

function SignalTest:draw()
  love.graphics.print(tostring( not self.disconnected), 0, 16)
  love.graphics.print('Dream', 50, 50)
end

return SignalTest