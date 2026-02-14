---
title: CuteSignal API
---

<section class="cs-hero">
  <p class="cs-eyebrow">Reference</p>
  <h1>API Reference</h1>
  <p>All signatures and behavior notes below match <code>CuteSignal.luau</code>.</p>
  <div class="cs-actions">
    <a class="cs-btn cs-btn-primary" href="index.html">Docs Home</a>
    <a class="cs-btn" href="benchmark.html">Benchmark</a>
  </div>
</section>

<nav class="cs-pill-nav">
  <a href="#exported-types">Types</a>
  <a href="#module-functions">Module</a>
  <a href="#signal-methods">Signal Methods</a>
  <a href="#destroyed-state">Destroyed State</a>
  <a href="#behavioral-details">Behavioral Details</a>
</nav>

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
- Wrapped events are dispatched through CuteSignal's `Fire` path.

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

## Destroyed State
After `Destroy()` is called:

| Method | Behavior |
| --- | --- |
| `Connect` | Throws `"Signal is destroyed"` |
| `Once` | Throws `"Signal is destroyed"` |
| `Wait` | Throws `"Signal is destroyed"` |
| `Fire` | No-op |
| `DisconnectAll` | No-op |
| `Destroy` | No-op |

## Connection Method

### `connection:Disconnect()`
Disconnects this connection. Safe to call more than once.

## Behavioral Details
- Listener execution order is last-connected, first-called.
- Waiters resume after listeners when both are present.
- `DisconnectAll()` clears listeners and waiters without resuming waiters.
- Callback errors propagate; callbacks are not wrapped in `pcall`.

<p class="cs-note"><strong>Implementation note:</strong> disconnects that happen while firing are deferred until outermost dispatch completes.</p>
