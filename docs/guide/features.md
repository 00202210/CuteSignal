# Features

## Runtime characteristics
### Optimized fire paths

`CuteSignal` has specialized dispatch branches for:

- no listeners and no waiters
- exactly one listener and no waiters
- listener iteration when there are no `:Once` listeners

### Reentry-safe cleanup

Disconnects that happen during `:Fire` are deferred and compacted once the outermost dispatch finishes.
This keeps iteration behavior stable when callbacks mutate signal state.

## Lifecycle guarantees

After calling `:Destroy()`:

- `:Connect`, `:Once`, and `:Wait` throw `"Signal is destroyed"`.
- `:Fire`, `:DisconnectAll`, and `:Destroy` become no-ops.
