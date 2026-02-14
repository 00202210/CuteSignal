---
title: CuteSignal Docs
---

<section class="cs-hero">
  <p class="cs-eyebrow">Roblox Luau Library</p>
  <h1>CuteSignal Documentation</h1>
  <p>Typed, low-allocation signals built for hot paths and predictable runtime behavior.</p>
  <div class="cs-actions">
    <a class="cs-btn cs-btn-primary" href="#install">Get Started</a>
    <a class="cs-btn" href="api.html">API Reference</a>
    <a class="cs-btn" href="benchmark.html">Benchmarks</a>
  </div>
  <div class="cs-kpis">
    <div class="cs-kpi">
      <p class="label">Overall Rank</p>
      <p class="value">#1</p>
    </div>
    <div class="cs-kpi">
      <p class="label">Score</p>
      <p class="value">906.5</p>
    </div>
    <div class="cs-kpi">
      <p class="label">Coverage</p>
      <p class="value">100%</p>
    </div>
    <div class="cs-kpi">
      <p class="label">Iteration Count</p>
      <p class="value">500M/Test</p>
    </div>
  </div>
</section>

<nav class="cs-pill-nav">
  <a href="#install">Install</a>
  <a href="#quick-start">Quick Start</a>
  <a href="#api-quick-reference">Quick API</a>
  <a href="#runtime-semantics">Runtime Semantics</a>
  <a href="api.html">Full API</a>
  <a href="benchmark.html">Benchmark</a>
</nav>

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
<div class="cs-grid">
  <article class="cs-card">
    <h3>Typed payloads</h3>
    <p>Use generic signal payload types directly in Luau without wrapper boilerplate.</p>
  </article>
  <article class="cs-card">
    <h3>Low allocation pressure</h3>
    <p>Connection nodes and waiter nodes are pooled to reduce GC churn.</p>
  </article>
  <article class="cs-card">
    <h3>Fast dispatch paths</h3>
    <p>Optimized no-listener, one-listener, and no-<code>Once</code> hot paths.</p>
  </article>
  <article class="cs-card">
    <h3>Safe during reentry</h3>
    <p>Disconnects while firing are deferred and compacted when dispatch completes.</p>
  </article>
  <article class="cs-card">
    <h3>RBX signal bridging</h3>
    <p><code>Signal.wrap()</code> mirrors existing <code>RBXScriptSignal</code> sources.</p>
  </article>
</div>

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

## Runtime Semantics
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

<p class="cs-note"><strong>Note:</strong> benchmark deltas are environment-sensitive. Re-run in your target runtime for absolute comparisons.</p>

## Other Pages
<div class="cs-inline-links">
  <a href="api.html">API Reference</a>
  <a href="benchmark.html">Benchmark</a>
</div>
