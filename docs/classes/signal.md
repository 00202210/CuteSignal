---
outline: deep
---

# Signal

```lua
type Signal<T... = ...any> = {
    Connect: (self: Signal<T...>, callback: (T...) -> ()) -> () -> (),
    ConnectAsync: (self: Signal<T...>, callback: (T...) -> ()) -> () -> (),
    Once: (self: Signal<T...>, callback: (T...) -> ()) -> () -> (),
    Wait: (self: Signal<T...>) -> T...,
    Fire: (self: Signal<T...>, ...: T...) -> (),
    DisconnectAll: (self: Signal<T...>) -> (),
    Destroy: (self: Signal<T...>) -> (),
}
```

## Constructors

### new

Returns a new signal instance.

```lua
local Signal = require(path.to.CuteSignal)

local signal = Signal.new()
```

## Methods

### Connect

Connects a callback to the signal and returns the Disconnect function

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

local disconnect = signal:Connect(function(value: number)
    print("value", value)
end)

signal:Fire(10)
disconnect()
```

### ConnectAsync

Like [Connect], but callbacks run asynchronously before any synchronous connections.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

local disconnect = signal:Connect(function(value: number)
    print("value", value)
end)

signal:Fire(10)
disconnect()
```

### Once

Connects a callback that automatically disconnects after its first execution.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

signal:Once(function(text)
    print("once", text)
end)

signal:Fire("hello")
signal:Fire("world")
```

### Wait

Yields the current thread until the signal fires, then returns fired arguments.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

task.delay(1, function()
    signal:Fire("Hello", "world")
end)

local a, b = signal:Wait()
print(a, b)
```

### Fire

Fires the signal and passes arguments to listeners and waiters.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

signal:Connect(function(text)
    print("listener", text)
end)

task.spawn(function()
    print("waited", signal:Wait())
end)

signal:Fire("event")
```

### DisconnectAll

Disconnects all listeners and clears waiters.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

signal:Connect(function() print("A") end)
signal:Connect(function() print("B") end)

signal:DisconnectAll()
signal:Fire("nothing")
```

### Destroy

Permanently disables the signal and disconnects any internal wrapped RBX connection.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

signal:Destroy()

-- These throw "Signal is destroyed"
-- signal:Connect(function() end)
-- signal:Once(function() end)
-- signal:Wait()

-- These are no-ops
signal:Fire("ignored")
signal:DisconnectAll()
signal:Destroy()
```

## Behavioral notes

- Listener execution order is last-connected, first-called.
- Waiters resume after listeners when both exist.
- `DisconnectAll` clears waiters without resuming them.
- Sync callback errors propagate; callbacks are not wrapped with `pcall`.
