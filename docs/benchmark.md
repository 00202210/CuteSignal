---
title: CuteSignal Benchmark
---

<section class="cs-hero">
  <p class="cs-eyebrow">Performance</p>
  <h1>Benchmark Results</h1>
  <p>All tests use <strong>500,000,000 iterations per case</strong>. Values are microseconds (<code>us</code>) per iteration, so lower is faster.</p>
  <div class="cs-actions">
    <a class="cs-btn cs-btn-primary" href="index.html">Docs Home</a>
    <a class="cs-btn" href="api.html">API Reference</a>
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
      <p class="label">Tests</p>
      <p class="value">21</p>
    </div>
  </div>
</section>

<nav class="cs-pill-nav">
  <a href="#per-test-results">Per-Test Table</a>
  <a href="#overall-score">Overall Score</a>
  <a href="#notes">Notes</a>
</nav>

## Per-Test Results

| Test | CuteSignal | CuterSignal | SkidSignal | BludSignal | NamedSignal | LuauSignal | FastSignal |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| ConnectAndDisconnect | 0.065 us | 0.071 us | 0.066 us | 0.065 us | 0.121 us | 0.068 us | 0.083 us |
| ConnectFireDisconnect | 0.101 us | 0.106 us | 0.102 us | 0.102 us | 0.225 us | 0.341 us | 0.134 us |
| FireWithNoConnections | 0.018 us | 0.018 us | 0.018 us | 0.018 us | 0.040 us | 0.018 us | 0.022 us |
| FireOneArgument | 0.038 us | 0.038 us | 0.038 us | 0.038 us | 0.101 us | 0.242 us | 0.045 us |
| Fire | 0.036 us | 0.037 us | 0.037 us | 0.037 us | 0.098 us | 0.241 us | 0.043 us |
| CreateAndFire | 0.352 us | 0.349 us | 0.349 us | 0.351 us | 0.299 us | 0.394 us | 0.161 us |
| OnceConnectAndFire | 0.092 us | 0.096 us | 0.091 us | 0.091 us | 0.294 us | 0.406 us | 0.195 us |
| FireManyArguments | 0.041 us | 0.041 us | 0.041 us | 0.041 us | 0.110 us | 0.245 us | 0.049 us |
| FireSingleArgumentTable | 0.037 us | 0.037 us | 0.037 us | 0.037 us | 0.099 us | 0.241 us | 0.044 us |
| FireManyHandlers | 0.424 us | 0.424 us | 0.423 us | 0.425 us | 1.856 us | 0.883 us | 0.318 us |
| Fire256Handlers | 3.105 us | 3.103 us | 3.100 us | 3.118 us | 14.091 us | 5.412 us | 2.245 us |
| ConnectManyThenFire | 0.806 us | 0.806 us | 0.807 us | 0.810 us | 3.594 us | 1.530 us | 0.588 us |
| ConnectAndDisconnectMany | 4.561 us | 4.863 us | 4.645 us | 4.576 us | 12.608 us | 6.656 us | 8.507 us |
| FireAfterManyDisconnects | 0.014 us | 0.014 us | 0.014 us | 0.014 us | 0.041 us | 0.019 us | 0.022 us |
| DisconnectDuringFire | 0.040 us | 0.040 us | 0.040 us | 0.040 us | 0.098 us | 0.244 us | 0.047 us |
| ConnectDuringFire | 0.063 us | 0.063 us | 0.063 us | 0.063 us | 0.152 us | 0.267 us | 0.056 us |
| ReentrantFire | 0.080 us | 0.080 us | 0.080 us | 0.080 us | 0.279 us | 1.719 us | 0.099 us |
| DisconnectAll | 2.292 us | 2.714 us | 2.333 us | 2.300 us | 8.794 us | 2.428 us | 4.923 us |
| WaitOnEvent | 0.598 us | 0.599 us | 0.590 us | 0.587 us | 0.865 us | 1.187 us | 0.928 us |
| WaitOnEventWithArgs | 0.637 us | 0.674 us | 0.669 us | 0.664 us | 0.908 us | 1.195 us | 0.988 us |
| WaitManyAtOnce | 12.665 us | 12.984 us | 13.476 us | 13.587 us | 17.083 us | 17.456 us | 17.845 us |

## Overall Score

Weighted geometric mean vs best per test (higher is better).

| Rank | Signal | Score | Coverage |
| ---: | --- | ---: | ---: |
| 1 | CuteSignal | 906.5 | 100.0% |
| 2 | BludSignal | 903.6 | 100.0% |
| 3 | SkidSignal | 902.3 | 100.0% |
| 4 | CuterSignal | 889.9 | 100.0% |
| 5 | FastSignal | 813.4 | 100.0% |
| 6 | NamedSignal | 339.1 | 100.0% |
| 7 | LuauSignal | 286.7 | 100.0% |

## Notes
- Absolute timings depend on hardware, Luau runtime version, and benchmark harness details.
- Relative rankings are most useful when rerun in your target environment.
- `CreateAndFire`, `FireManyHandlers`, and `Fire256Handlers` are cases where another implementation can win despite CuteSignal leading overall.

<p class="cs-note"><strong>Recommendation:</strong> use per-test comparisons to evaluate your specific workload, not just the aggregate score.</p>
