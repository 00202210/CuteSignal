# Features

## Runtime characteristics

### Connection node pooling

Disconnected listeners are recycled instead of discarded.
That reduces allocation churn in connect/disconnect-heavy code paths.

### Waiter node pooling

Waiting coroutines are tracked with pooled waiter nodes that are reused after resume.

### Optimized fire paths

`CuteSignal` has specialized dispatch branches for:

- no listeners and no waiters
- exactly one listener and no waiters
- listener iteration when there are no `:Once` listeners

### Reentry-safe cleanup

Disconnects that happen during `:Fire` are deferred and compacted once the outermost dispatch finishes.
This keeps iteration behavior stable when callbacks mutate signal state.

## Roblox interoperability

Wrap native Roblox events and consume them through the same API:

```lua
local Signal = require(path.to.CuteSignal)

local bindable = Instance.new("BindableEvent")
local wrapped = Signal.wrap(bindable.Event)

wrapped:Connect(function(msg)
    print("wrapped", msg)
end)

bindable:Fire("hello")
```

## Lifecycle guarantees

After calling `:Destroy()`:

- `:Connect`, `:Once`, and `:Wait` throw `"Signal is destroyed"`.
- `:Fire`, `:DisconnectAll`, and `:Destroy` become no-ops.
