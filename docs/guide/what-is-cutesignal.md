# What is CuteSignal?

`CuteSignal` is a pure Luau signal module designed for predictable behavior under load.
It keeps the API small, avoids unnecessary allocations, and makes edge-case behavior explicit.

## Core API

`CuteSignal` exposes the standard methods most Roblox developers expect:

- `:Connect`
- `:Once`
- `:Wait`
- `:Fire`
- `:DisconnectAll`
- `:Destroy`

It also provides `Signal.wrap` to mirror `RBXScriptSignal` sources.

## Behavioral contract

These rules are intentional and stable:

- Listener order is newest-to-oldest.
- `:Once` listeners disconnect before their callback runs.
- Waiters resume after listeners when both exist.
- `:DisconnectAll` clears waiters without resuming them.
- After `:Destroy()`, connect/once/wait throw `"Signal is destroyed"`, while fire/disconnectAll/destroy are no-ops.

## Why this shape

`CuteSignal` stays close to common signal conventions so migration from other Luau signal implementations is straightforward, while still targeting lower runtime overhead.
