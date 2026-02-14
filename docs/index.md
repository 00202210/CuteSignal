---
title: CuteSignal
---

# CuteSignal

A fast typed Signal implementation for Roblox Luau.

## Install
- Copy `CuteSignal.luau` into your project
- `local Signal = require(path.to.CuteSignal)`

## Quickstart
```lua
local Signal = require(path.to.CuteSignal)

local s = Signal.new()

s:Connect(function(x)
	print("got", x)
end)

s:Fire(123)
