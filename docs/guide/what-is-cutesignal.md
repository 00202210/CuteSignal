# What is CuteSignal?

`CuteSignal` is a pure Luau signal module designed for predictable behavior under load.
It keeps the API small, avoids unnecessary allocations, and makes edge-case behavior explicit.

## Core API

`CuteSignal` exports `Signal.new()` and each signal instance provides:

- `:Connect`
- `:ConnectAsync`
- `:Once`
- `:Wait`
- `:Fire`
- `:DisconnectAll`
- `:Destroy`
- `:Count`
- `:HasConnections`
- `:IsDestroyed`

## Behavioral contract

These rules are intentional and stable:

- Listener order is newest-to-oldest for both sync and async listeners.
- Async listeners are dispatched before sync listeners.
- `:Once` listeners disconnect before their callback runs.
- Waiters resume after listeners when both exist.
- `:DisconnectAll` clears waiters without resuming them.
- After `:Destroy()`, `:Connect`, `:ConnectAsync`, and `:Wait` throw `"Signal is destroyed"`.
- After `:Destroy()`, `:Fire`, `:DisconnectAll`, and `:Destroy` are no-ops.

## Why this shape

`CuteSignal` stays close to common signal conventions so migration from other Luau signal implementations is straightforward, while still targeting lower runtime overhead.
