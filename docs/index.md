---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  text: "A fast and low-allocation pure Luau signal."
  image:
    src: /icon.png
    alt: CuteSignal icon
  actions:
    - theme: brand
      text: Get Started
      link: /guide/what-is-cutesignal
    - theme: alt
      text: API Reference
      link: /classes/signal

features:
  - title: 🧠 Typed Luau API
    details: Simple generic signal types with familiar Roblox-style methods.
  - title: ♻ Pooled internals
    details: Connection and waiter nodes are recycled to reduce allocation and GC pressure.
  - title: 🔁 Reentry-safe firing
    details: Deferred disconnect cleanup keeps behavior stable during nested or reentrant fires.
---
