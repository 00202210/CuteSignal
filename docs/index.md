---
layout: home

hero:
  name: "CuteSignal"
  text: "Predictable events for Roblox Luau"
  tagline: "Fast paths, pooled internals, and explicit lifecycle rules."
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
    details: Fast dispatch branches and node pooling reduce overhead in high-frequency event systems.
  - title: Roblox event bridging
    details: Wrap RBXScriptSignal sources and use the same CuteSignal API across native and wrapped events.
---

## Quick install

```lua
local Signal = require(path.to.CuteSignal)
```

## At a glance

- `Signal.new()` creates standalone signals.
- `Signal.wrap(rbxSignal)` forwards a Roblox event through CuteSignal.
- `Connection:Disconnect()` is idempotent and safe to call repeatedly.

For full method signatures, open [Signal Documentation](/classes/signal).
