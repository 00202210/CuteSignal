--!strict
--!native

--[[
	CuteSignal
	- Sync listeners fire immediately.
	- Async listeners run through a reusable coroutine runner.
	- Waiters suspend and resume on the next fire.
]]

-- Type definitions
type Callback = (...any) -> ()
export type Disconnect = () -> ()

type SignalCore = {
	Fire: (self: Signal, ...any) -> (),
	Connect: (self: Signal, callback: Callback) -> Disconnect,
	ConnectAsync: (self: Signal, callback: Callback) -> Disconnect,
	Wait: (self: Signal) -> ...any,
	DisconnectAll: (self: Signal) -> (),
	Destroy: (self: Signal) -> (),
	Count: (self: Signal) -> number,
}

export type Signal = SignalCore & {
	Once: (self: Signal, callback: Callback) -> Disconnect,
	HasConnections: (self: Signal) -> boolean,
	IsDestroyed: (self: Signal) -> boolean,
}

type Slot = {
	index: number,
	generation: number,
}

type FireFn = (self: Signal, ...any) -> ()

-- Localized globals
local table_create = table.create
local table_clear = table.clear
local table_freeze = table.freeze
local coroutine_create = coroutine.create
local coroutine_resume = coroutine.resume
local coroutine_running = coroutine.running
local coroutine_yield = coroutine.yield

-- Async callback runner cache.
-- Reuses one coroutine when async handlers do not yield, reducing allocations.
local freeAsyncRunnerThread: thread? = nil

local function RunAsyncCallback(callback: Callback, ...): ()
	local runner = freeAsyncRunnerThread
	freeAsyncRunnerThread = nil
	callback(...)
	freeAsyncRunnerThread = runner
end

local function AsyncRunnerLoop(): ()
	while true do
		RunAsyncCallback(coroutine_yield())
	end
end

local function DispatchAsyncRunner(callback: Callback, ...): ()
	local runner = freeAsyncRunnerThread
	if runner == nil then
		runner = coroutine_create(AsyncRunnerLoop)
		coroutine_resume(runner :: thread)
		freeAsyncRunnerThread = runner
	end
	coroutine_resume(runner :: thread, callback, ...)
end

-- No-op and destroyed-state handlers.
-- These keep hot paths branch-light by swapping function references.
local function NoopFire(_self: Signal, ...): ()
	return
end

local function NoopDisconnectAll(_self: Signal): ()
	return
end

local function NoopDestroy(_self: Signal): ()
	return
end

local function ZeroCount(_self: Signal): number
	return 0
end

local function DestroyedConnect(_self: Signal, _callback: Callback): never
	error("Signal is destroyed")
end

local function DestroyedWait(_self: Signal): never
	error("Signal is destroyed")
end

-- Shared methods exposed through the metatable.
local function SignalOnce(self: Signal, callback: Callback): Disconnect
	if type(callback) ~= "function" then
		error("Once expects a function callback")
	end

	local disconnect = nil :: any
	disconnect = self:Connect(function(...: any)
		disconnect()
		callback(...)
	end)

	return disconnect
end

local function SignalHasConnections(self: Signal): boolean
	return self:Count() ~= 0
end

local function SignalIsDestroyed(self: Signal): boolean
	return self.Connect == DestroyedConnect
end

local SIGNAL_METHODS = table_freeze({
	Once = SignalOnce,
	HasConnections = SignalHasConnections,
	IsDestroyed = SignalIsDestroyed,
})

local SIGNAL_METATABLE = table_freeze({
	__index = SIGNAL_METHODS,
})

-- Signal constructor.
local function NewSignal(): Signal
	-- Sync listener state
	local syncCount = 0
	local syncGeneration = 1
	local syncCallbacks = {} :: { [number]: Callback? }
	local syncSlots = {} :: { [number]: Slot? }

	-- Async listener state
	local asyncCount = 0
	local asyncGeneration = 1
	local asyncCallbacks = {} :: { [number]: Callback? }
	local asyncSlots = {} :: { [number]: Slot? }

	-- Waiting coroutine state
	local waitCount = 0
	local waitThreads = {} :: { [number]: thread? }

	local signal: Signal
	local syncFire: FireFn = NoopFire
	local asyncFire: FireFn = NoopFire
	local baseFire: FireFn = NoopFire
	local fireWithWait: FireFn

	-- Recomputes the currently active `Fire` implementation.
	-- Waiters wrap the combined listener fire path when present.
	local function RebuildFire(): ()
		local fireNoWait: FireFn

		if asyncCount == 0 then
			fireNoWait = syncFire
		elseif syncCount == 0 then
			fireNoWait = asyncFire
		else
			fireNoWait = function(self: Signal, ...: any): ()
				asyncFire(self, ...)
				syncFire(self, ...)
			end
		end

		baseFire = fireNoWait
		if waitCount == 0 then
			signal.Fire = fireNoWait
		else
			signal.Fire = fireWithWait
		end
	end

	-- Rebuild sync dispatch function using a stable snapshot.
	local function RebuildSyncFire(): ()
		local fire: FireFn

		if syncCount == 0 then
			fire = NoopFire
		elseif syncCount == 1 then
			fire = function(_self: Signal, ...: any): ()
				(syncCallbacks[1] :: Callback)(...)
			end
		else
			local snapshot = table_create(syncCount) :: { [number]: Callback }
			local source = syncCount
			for i = 1, syncCount do
				-- Newest-first execution order.
				snapshot[i] = syncCallbacks[source] :: Callback
				source -= 1
			end

			local snap = snapshot
			local n = syncCount
			fire = function(_self: Signal, ...: any): ()
				for i = 1, n do
					(snap[i] :: Callback)(...)
				end
			end
		end

		syncFire = fire
		RebuildFire()
	end

	-- Rebuild async dispatch function using a stable snapshot.
	local function RebuildAsyncFire(): ()
		local fire: FireFn

		if asyncCount == 0 then
			fire = NoopFire
		else
			local snapshot = table_create(asyncCount) :: { [number]: Callback }
			local source = asyncCount
			for i = 1, asyncCount do
				-- Newest-first execution order.
				snapshot[i] = asyncCallbacks[source] :: Callback
				source -= 1
			end

			local snap = snapshot
			local n = asyncCount
			fire = function(_self: Signal, ...: any): ()
				for i = 1, n do
					DispatchAsyncRunner(snap[i] :: Callback, ...)
				end
			end
		end

		asyncFire = fire
		RebuildFire()
	end

	-- Suspend the current coroutine until the next fire.
	local function Wait(self: Signal): ...any
		if self.Connect == DestroyedConnect then
			error("Signal is destroyed")
		end

		local thread = coroutine_running()
		if thread == nil then
			error("Wait must be called from a running coroutine")
		end

		local index = waitCount + 1
		waitCount = index
		waitThreads[index] = thread
		if index == 1 then
			signal.Fire = fireWithWait
		end

		return coroutine_yield()
	end

	-- Fire path used while at least one thread is waiting.
	fireWithWait = function(self: Signal, ...: any): ()
		local n = waitCount
		if n == 0 then
			signal.Fire = baseFire
			baseFire(self, ...)
			return
		end

		local snapshot = table_create(n) :: { [number]: thread }
		for i = 1, n do
			snapshot[i] = waitThreads[i] :: thread
			waitThreads[i] = nil
		end
		waitCount = 0

		-- Return to no-wait fast path before listener execution.
		signal.Fire = baseFire
		baseFire(self, ...)

		for i = 1, n do
			coroutine_resume(snapshot[i] :: thread, ...)
		end
	end

	-- Register a synchronous callback.
	local function Connect(_self: Signal, callback: Callback): Disconnect
		if type(callback) ~= "function" then
			error("Connect expects a function callback")
		end

		local index = syncCount + 1
		syncCount = index
		syncCallbacks[index] = callback

		local slot = {
			index = index,
			generation = syncGeneration,
		}
		syncSlots[index] = slot

		RebuildSyncFire()

		return function(): ()
			if slot.generation ~= syncGeneration then
				return
			end

			local removeIndex = slot.index
			if removeIndex == 0 then
				return
			end

			local last = syncCount
			if removeIndex ~= last then
				-- O(1) remove by moving the last callback into the removed slot.
				syncCallbacks[removeIndex] = syncCallbacks[last]
				syncCallbacks[last] = nil

				local movedSlot = syncSlots[last]
				syncSlots[removeIndex] = movedSlot
				syncSlots[last] = nil
				if movedSlot ~= nil then
					movedSlot.index = removeIndex
				end
			else
				syncCallbacks[last] = nil
				syncSlots[last] = nil
			end

			syncCount = last - 1
			slot.index = 0
			RebuildSyncFire()
		end
	end

	-- Register an asynchronous callback.
	local function ConnectAsync(_self: Signal, callback: Callback): Disconnect
		if type(callback) ~= "function" then
			error("ConnectAsync expects a function callback")
		end

		local index = asyncCount + 1
		asyncCount = index
		asyncCallbacks[index] = callback

		local slot = {
			index = index,
			generation = asyncGeneration,
		}
		asyncSlots[index] = slot

		RebuildAsyncFire()

		return function(): ()
			if slot.generation ~= asyncGeneration then
				return
			end

			local removeIndex = slot.index
			if removeIndex == 0 then
				return
			end

			local last = asyncCount
			if removeIndex ~= last then
				-- O(1) remove by moving the last callback into the removed slot.
				asyncCallbacks[removeIndex] = asyncCallbacks[last]
				asyncCallbacks[last] = nil

				local movedSlot = asyncSlots[last]
				asyncSlots[removeIndex] = movedSlot
				asyncSlots[last] = nil
				if movedSlot ~= nil then
					movedSlot.index = removeIndex
				end
			else
				asyncCallbacks[last] = nil
				asyncSlots[last] = nil
			end

			asyncCount = last - 1
			slot.index = 0
			RebuildAsyncFire()
		end
	end

	-- Clear all listeners and waiters, and reset dispatch fast paths.
	local function DisconnectAll(_self: Signal): ()
		if syncCount == 0 and asyncCount == 0 and waitCount == 0 then
			return
		end

		syncGeneration += 1
		asyncGeneration += 1
		syncCount = 0
		asyncCount = 0
		waitCount = 0
		table_clear(syncCallbacks)
		table_clear(syncSlots)
		table_clear(asyncCallbacks)
		table_clear(asyncSlots)
		table_clear(waitThreads)

		syncFire = NoopFire
		asyncFire = NoopFire
		baseFire = NoopFire
		signal.Fire = NoopFire
	end

	-- Permanently disable the signal instance.
	local function Destroy(self: Signal): ()
		DisconnectAll(self)
		signal.Connect = DestroyedConnect
		signal.ConnectAsync = DestroyedConnect
		signal.Wait = DestroyedWait
		signal.DisconnectAll = NoopDisconnectAll
		signal.Destroy = NoopDestroy
		signal.Count = ZeroCount
	end

	local function Count(_self: Signal): number
		return syncCount + asyncCount
	end

	signal = {
		Fire = NoopFire,
		Connect = Connect,
		ConnectAsync = ConnectAsync,
		Wait = Wait,
		DisconnectAll = DisconnectAll,
		Destroy = Destroy,
		Count = Count,
	} :: Signal

	-- Cast through `any` to satisfy strict typing around metatable extension.
	return (setmetatable(signal :: Signal, SIGNAL_METATABLE) :: any) :: Signal
end

return table_freeze({
	new = NewSignal,
})
