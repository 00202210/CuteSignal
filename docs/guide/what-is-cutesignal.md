# What is CuteSignal?

`CuteSignal` is a pure Luau signal implementation focused on predictable runtime behavior and low overhead in Roblox workloads.
It supports the conventional signal API (`:Connect`, `:Once`, `:Wait`, `:Fire`, `:DisconnectAll`, `:Destroy`) plus `Signal.wrap` for bridging `RBXScriptSignal` events.

More implementation details are on the next pages.

## API Design

`CuteSignal` keeps the standard signal/connection shape so it is easy to swap in from other Lua/Luau signal libraries that follow the same conventions.

Key semantics:

- Listeners run newest-to-oldest.
- `:Once` listeners disconnect before callback execution.
- `:Wait` returns the exact arguments passed to `:Fire`.
- Callback errors propagate to the caller.
