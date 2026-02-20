---
layout: home

hero:
  name: "CuteSignal"
  text: "Predictable events for Roblox Luau"
  tagline: "Fast dispatch paths, coroutine-backed async listeners, and explicit lifecycle rules."
  image:
    src: /icon.png
    alt: CuteSignal icon
  actions:
    - theme: brand
      text: Start Here
      link: /guide/what-is-cutesignal
    - theme: alt
      text: API Reference
      link: /classes/signal
    - theme: alt
      text: Benchmarks
      link: /guide/performance

features:
  - title: Small API, clear behavior
    details: Familiar methods with well-defined semantics for fire order, once listeners, waits, and destruction.
  - title: Optimized for hot paths
    details: Specialized fire branches, swap-remove disconnects, and snapshot dispatch keep event overhead low.
  - title: Sync and async listeners
    details: Connect async callbacks with :ConnectAsync and dispatch them through a reusable coroutine runner.
---

## Quick install

```lua
local Signal = require(path.to.CuteSignal)
```

## At a glance

- `Signal.new()` creates standalone signals.
- `:Connect`, `:ConnectAsync`, and `:Once` each return an idempotent `disconnect()` function.
- `:Count`, `:HasConnections`, and `:IsDestroyed` expose signal state.

For full method signatures, open [Signal Documentation](/classes/signal).
