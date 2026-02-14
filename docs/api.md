---
title: CuteSignal API
---

# API Reference

All signatures below match `CuteSignal.luau`.

<p>
  <a href="index.html" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Docs Home</a>
  <a href="benchmark.html" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Benchmark</a>
</p>

## Exported Types
```luau
export type Connection = {
	Disconnect: (self: Connection) -> (),
}

export type Signal<T... = ...any> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}
```

## Module Functions

### `Signal.new(): Signal<T...>`
Creates a new signal instance.

### `Signal.wrap(rbxSignal: RBXScriptSignal): Signal<T...>`
Creates a signal that forwards events from an `RBXScriptSignal`.

Notes:
- The wrapped RBX connection is stored internally.
- Calling `Destroy()` disconnects that internal RBX connection.
- Wrapped events are dispatched through CuteSignal's `Fire` path, so listener/waiter behavior is identical to `Signal.new()`.

## Signal Methods

### `signal:Connect(callback: (T...) -> ()): Connection`
Registers a persistent listener.

Notes:
- Newest listeners run first.
- The returned connection is reusable and can be disconnected at any time.

### `signal:Once(callback: (T...) -> ()): Connection`
Registers a listener that auto-disconnects before callback execution.

### `signal:Wait(): T...`
Yields the current thread until the next `Fire(...)`, then returns those fired values.

Notes:
- Waiters resume after listeners if listeners are present.
- `DisconnectAll()` clears waiters without resuming them.

### `signal:Fire(...: T...)`
Dispatches to connected listeners and resumes waiters.

Notes:
- Supports reentrant calls (`Fire()` from inside a callback).
- Disconnects during dispatch are deferred and compacted after outermost dispatch completes.
- Callback errors are not caught and propagate to the caller.

### `signal:DisconnectAll()`
Removes all listeners and clears any waiting coroutines.

### `signal:Destroy()`
Permanently disables the signal and disconnects wrapped RBX connections.

After `Destroy()`:
- `Connect`, `Once`, and `Wait` error with `"Signal is destroyed"`.
- `Fire`, `DisconnectAll`, and `Destroy` become no-ops.

## Connection Method

### `connection:Disconnect()`
Disconnects this connection. Safe to call more than once.

## Behavioral Details
- Listener execution order is last-connected, first-called.
- Waiters resume after listeners when both are present.
- Callback errors propagate; callbacks are not wrapped in `pcall`.
