# CuteSignal

CuteSignal is a fast, typed signal implementation for Roblox Luau.

## Features
- Generic Luau typing for signal payloads.
- Low-allocation hot paths using pooled connection and waiter nodes.
- Fast dispatch paths for no-listener, single-listener, and no-`Once` scenarios.
- Safe disconnects during `Fire()` with deferred cleanup.
- `Signal.wrap()` to mirror existing `RBXScriptSignal`s.

## Installation
1. Copy `CuteSignal.luau` into your project.
2. Require it:

```luau
local Signal = require(path.to.CuteSignal)
```

## Quick Start
```luau
local Signal = require(path.to.CuteSignal)

local DamageTaken = Signal.new()

local connection = DamageTaken:Connect(function(amount)
	print("damage:", amount)
end)

DamageTaken:Once(function(amount)
	print("first hit only:", amount)
end)

task.spawn(function()
	local amount = DamageTaken:Wait()
	print("waited:", amount)
end)

DamageTaken:Fire(25)
connection:Disconnect()
DamageTaken:Destroy()
```

## API Surface
- `Signal.new(): Signal<T...>`
- `Signal.wrap(rbxSignal: RBXScriptSignal): Signal<T...>`
- `signal:Connect(callback): Connection`
- `signal:Once(callback): Connection`
- `signal:Wait(): T...`
- `signal:Fire(...: T...)`
- `signal:DisconnectAll()`
- `signal:Destroy()`
- `connection:Disconnect()`

## Behavior Notes
- Listeners run newest-to-oldest.
- `Once` listeners disconnect before callback execution.
- Waiters resume with exactly the values passed to `Fire(...)`.
- If listeners and waiters both exist, listeners run first, then waiters resume.
- `DisconnectAll()` clears listeners and waiters without resuming waiters.
- After `Destroy()`, `Connect`, `Once`, and `Wait` error with `"Signal is destroyed"`.
- After `Destroy()`, `Fire`, `DisconnectAll`, and `Destroy` are no-ops.

## Documentation
- Docs home: [Home](https://00202210.github.io/CuteSignal/)
- API reference: [API](https://00202210.github.io/CuteSignal/api.html)
- Benchmark details: [Benchmarks](https://00202210.github.io/CuteSignal/benchmark.html)
