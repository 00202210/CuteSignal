# Performance

Benchmarks are shown in microseconds (`us`) where lower is faster.

## :Fire()

![Fire benchmark chart](/benchmarks/fire.svg)

`CuteSignal` ranks **1st** in this chart (`16 us`). It does well here because dispatch is heavily optimized for the hot path: minimal per-fire overhead and no extra work unless needed.

## :Disconnect()

![Disconnect benchmark chart](/benchmarks/disconnect.svg)

`CuteSignal` is tied for **1st** (`5 us`). Disconnects stay cheap because the connection node is removed directly, and deeper cleanup is deferred when that keeps the current fire cycle stable.

## :Connect()

![Connect benchmark chart](/benchmarks/connect.svg)

`CuteSignal` ranks **2nd** (`130 us`). It is not the absolute fastest raw connect path in this set, but it keeps enough bookkeeping to make later operations (especially firing and disconnect behavior) more predictable.

## .new()

![new benchmark chart](/benchmarks/new.svg)

`CuteSignal` ranks **3rd** (`55 us`). Constructor work is slightly heavier because it sets up internal state used to keep runtime operations efficient after creation.

## Overall

![Overall benchmark chart](/benchmarks/overall.svg)

`CuteSignal` ranks **1st overall** (`274 us`). The strong fire and disconnect results offset the higher `.new()` and mid-pack `:Connect()` cost, so total runtime is lowest across the full set.
