# Features

## Runtime characteristics
### Optimized fire paths

`CuteSignal` swaps the active `:Fire` implementation based on state:

- no listeners: no-op fire path
- one sync listener: direct callback fast path
- mixed listener sets: async listeners first, then sync listeners
- waiters present: listeners fire first, then waiting threads resume

### Low-overhead listener management

- Disconnect uses swap-remove for `O(1)` listener removal.
- Dispatch snapshots are rebuilt on connect/disconnect to keep iteration stable.
- Disconnect functions are idempotent, and stale disconnects are ignored via generation checks.

### Async runner reuse

`:ConnectAsync` callbacks run through a reusable coroutine runner cache.
If a callback yields, additional runners are allocated as needed.

## Lifecycle guarantees

After calling `:Destroy()`:

- `:Connect`, `:ConnectAsync`, and `:Wait` throw `"Signal is destroyed"`.
- `:Fire`, `:DisconnectAll`, and `:Destroy` become no-ops.
- `:Count()` returns `0`, `:HasConnections()` returns `false`, and `:IsDestroyed()` returns `true`.
