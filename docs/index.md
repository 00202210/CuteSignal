---
title: CuteSignal Docs
---

# CuteSignal Documentation

CuteSignal is a typed, allocation-aware signal module for Roblox Luau.

<p>
  <a href="#install" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Install</a>
  <a href="#quick-start" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Quick Start</a>
  <a href="#api-quick-reference" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Quick API</a>
  <a href="api.html" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Full API</a>
  <a href="#behavior-notes" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Behavior Notes</a>
  <a href="benchmark.html" style="display:inline-block;padding:8px 12px;margin:4px;border:1px solid #2f6f44;border-radius:6px;text-decoration:none;">Benchmark</a>
</p>

## Install
1. Copy `CuteSignal.luau` into your project.
2. Require it from your code:

```luau
local Signal = require(path.to.CuteSignal)
```

## Quick Start
```luau
local Signal = require(path.to.CuteSignal)

local DamageTaken = Signal.new()

local connection = DamageTaken:Connect(function(amount: number)
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

## Why CuteSignal
- Generic Luau typing for signal payloads.
- Pooled connection and waiter nodes to reduce allocation churn.
- Fast paths for no listeners, one listener, and no-`Once` dispatch.
- Safe disconnect handling during reentrant `Fire()` calls.
- Optional wrapping of existing `RBXScriptSignal`s.

## Module Surface
- `Signal.new()` creates a standalone signal.
- `Signal.wrap(rbxSignal)` forwards a `RBXScriptSignal` through CuteSignal's API.
- Signal instances expose `Connect`, `Once`, `Wait`, `Fire`, `DisconnectAll`, and `Destroy`.

See the dedicated API page for signatures and edge-case details: [API Reference](api.html).

## API Quick Reference

### `Signal.new(): Signal<T...>`
Creates a standalone signal instance.

### `Signal.wrap(rbxSignal: RBXScriptSignal): Signal<T...>`
Creates a signal that mirrors an `RBXScriptSignal` and can be consumed with CuteSignal methods.

### `signal:Connect(callback: (T...) -> ()): Connection`
Adds a persistent listener.

### `signal:Once(callback: (T...) -> ()): Connection`
Adds a listener that disconnects before it runs once.

### `signal:Wait(): T...`
Yields until the next `Fire(...)`, then returns fired values.

### `signal:Fire(...: T...)`
Dispatches to listeners and resumes waiters.

### `signal:DisconnectAll()`
Removes all listeners and clears waiters.

### `signal:Destroy()`
Disables the signal permanently and disconnects wrapped RBX connection state.

## Behavior Notes
1. Listener call order is newest-to-oldest.
2. `Once` listeners are removed before their callback runs.
3. `Wait` resumes with the exact values from `Fire(...)`.
4. If listeners and waiters are both present, listeners run before waiters resume.
5. `DisconnectAll` removes listeners and clears waiters without resuming them.
6. After `Destroy`, `Connect`, `Once`, and `Wait` throw `"Signal is destroyed"`.
7. After `Destroy`, `Fire`, `DisconnectAll`, and `Destroy` are no-ops.
8. Callback errors are not swallowed; they propagate to the caller.

## Performance Notes
- Connection nodes are pooled and reused to reduce allocation and GC pressure.
- Waiter nodes are pooled, reducing coroutine wait bookkeeping cost.
- `Fire` has a single-listener fast path to minimize overhead in common cases.
- `Fire` has a no-`Once` fast path that avoids extra branching/bookkeeping.
- Disconnects during `Fire` are deferred, then compacted once dispatch finishes.
- Workloads with many removals during dispatch can be slower due to post-fire compaction.

## Benchmark Snapshot
Benchmarks were run with **500,000,000 iterations per test**.

| Rank | Signal | Score | Coverage |
| ---: | --- | ---: | ---: |
| 1 | CuteSignal | 906.5 | 100.0% |
| 2 | BludSignal | 903.6 | 100.0% |
| 3 | SkidSignal | 902.3 | 100.0% |
| 4 | CuterSignal | 889.9 | 100.0% |
| 5 | FastSignal | 813.4 | 100.0% |
| 6 | NamedSignal | 339.1 | 100.0% |
| 7 | LuauSignal | 286.7 | 100.0% |

Full scenario table: [Benchmark](benchmark.html)

## Other Pages
- [API Reference](api.html)
- [Benchmark](benchmark.html)
