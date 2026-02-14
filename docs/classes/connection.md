---
outline: deep
---

# Connection

```lua
type Connection = {
    Disconnect: (self: Connection) -> (),
}
```

## Methods

### Disconnect

Disconnects the connection from the signal.
Safe to call more than once.

```lua
local Signal = require(path.to.CuteSignal)
local signal = Signal.new()

local connection = signal:Connect(function(text)
    print(text)
end)

signal:Fire("hello")
connection:Disconnect()
signal:Fire("world")
```
