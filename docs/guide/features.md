# Features

## Connection pooling

`CuteSignal` recycles connection nodes after disconnects.
This helps reduce table churn in connect/disconnect heavy paths.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

for _ = 1, 1000 do
    local connection = signal:Connect(function() end)
    connection:Disconnect()
end
```

## Waiter pooling

Waiting coroutines are tracked through pooled waiter nodes.
After resume, waiter nodes are recycled for future `:Wait` calls.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

task.spawn(function()
    local a, b = signal:Wait()
    print(a, b)
end)

signal:Fire("hello", "world")
```

## Fire-path optimizations

`CuteSignal` includes specialized `:Fire` paths for common cases:

- No listeners and no waiters.
- One listener and no waiters.
- Listener iteration when there are no `:Once` listeners.

## Safe mutation during fire

Disconnects that happen while firing are deferred and compacted after the outermost dispatch finishes.
This keeps callback iteration stable when callbacks mutate listener state.

## RBXScriptSignal wrapping

Use `Signal.wrap` to mirror Roblox events through the same `CuteSignal` API.

```lua
local Signal = require(path.to.CuteSignal)

local bindable = Instance.new("BindableEvent")
local wrapped = Signal.wrap(bindable.Event)

wrapped:Connect(function(message)
    print("wrapped", message)
end)

bindable:Fire("event")
```

## Destroy contract

After `:Destroy()`:

- `:Connect`, `:Once`, and `:Wait` throw `"Signal is destroyed"`.
- `:Fire`, `:DisconnectAll`, and `:Destroy` become no-ops.
