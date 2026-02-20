---
outline: deep
---

# Signal

```lua
type Disconnect = () -> ()

type Signal<T... = ...any> = {
    Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Disconnect,
    ConnectAsync: (self: Signal<T...>, callback: (T...) -> ()) -> Disconnect,
    Once: (self: Signal<T...>, callback: (T...) -> ()) -> Disconnect,
    Wait: (self: Signal<T...>) -> T...,
    Fire: (self: Signal<T...>, ...: T...) -> (),
    DisconnectAll: (self: Signal<T...>) -> (),
    Destroy: (self: Signal<T...>) -> (),
    Count: (self: Signal<T...>) -> number,
    HasConnections: (self: Signal<T...>) -> boolean,
    IsDestroyed: (self: Signal<T...>) -> boolean,
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

Like `Connect`, but callbacks run via an async coroutine runner.
When both listener types are present, async listeners are dispatched before sync listeners.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

local disconnect = signal:ConnectAsync(function(value: number)
    print("async", value)
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
Must be called from a running coroutine.

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

Permanently disables the signal.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

signal:Destroy()

-- These throw "Signal is destroyed"
-- signal:Connect(function() end)
-- signal:ConnectAsync(function() end)
-- signal:Once(function() end)
-- signal:Wait()

-- These are no-ops
signal:Fire("ignored")
signal:DisconnectAll()
signal:Destroy()
```

### Count

Returns the number of connected listeners (`Connect` + `ConnectAsync`).

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

local a = signal:Connect(function() end)
local b = signal:ConnectAsync(function() end)

print(signal:Count()) -- 2
```

### HasConnections

Returns `true` when `:Count() ~= 0`.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

print(signal:HasConnections()) -- false
local disconnect = signal:Connect(function() end)
print(signal:HasConnections()) -- true
```

### IsDestroyed

Returns `true` after `:Destroy()` has been called.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

print(signal:IsDestroyed()) -- false
signal:Destroy()
print(signal:IsDestroyed()) -- true
```

## Behavioral notes

- Listener execution order is last-connected, first-called within each listener set.
- Async listeners dispatch before sync listeners when both exist.
- Waiters resume after listeners when both exist.
- `DisconnectAll` clears waiters without resuming them.
- Disconnect functions are idempotent.
