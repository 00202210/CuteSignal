--!strict
--!optimize 2
--!native

--[[

	 ******       ******
   **********   **********
 ************* *************
*****************************
*****************************
*****************************
 ***************************
   ***********************
     *******************
       ***************
         ***********
           *******
             ***
              *

]]

export type Connection = {
	Disconnect: (self: Connection) -> (),
}

export type Signal<T... = ...any> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Wait: (self: Signal<T...>) -> T...,
	Fire: (self: Signal<T...>, T...) -> (),
	DisconnectAll: (self: Signal<T...>) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

local error_local = error
local table_freeze = table.freeze
local coroutine_running = coroutine.running
local coroutine_yield = coroutine.yield
local coroutine_resume = coroutine.resume

local SIGNAL_DESTROYED_ERROR = "Signal is destroyed"

local connection_pool_head: any = nil
local wait_pool_head: any = nil

local function RecycleConnectionNode(node: any): ()
	node._signal = nil
	node._callback = nil
	node._once = false
	node._index = 0
	node._next = connection_pool_head
	connection_pool_head = node
end

local function DrainPendingFree(signal: any): ()
	local node = signal._pendingFree
	if node == nil then
		return
	end

	signal._pendingFree = nil
	local pool_head = connection_pool_head
	while node do
		local pending_next = node._next
		node._next = pool_head
		pool_head = node
		node = pending_next
	end
	connection_pool_head = pool_head
end

local function RecycleWaitNode(node): ()
	node.thread = nil
	node.next = wait_pool_head
	wait_pool_head = node
end

local function AcquireWaitNode(waiting_thread: thread): any
	local node = wait_pool_head
	if node ~= nil then
		wait_pool_head = node.next
		node.thread = waiting_thread
		node.next = nil
		return node
	end

	return {
		thread = waiting_thread,
		next = nil,
	}
end

local function CompactConnections(signal: any): ()
	local count = signal._count
	local write_index = 1

	for read_index = 1, count do
		local node = signal[read_index]
		if node ~= nil then
			if write_index ~= read_index then
				signal[write_index] = node
				signal[read_index] = nil
				node._index = write_index
			end
			write_index += 1
		end
	end

	signal._count = write_index - 1
	signal._deadCount = 0
end

local function DisconnectNode(node: any): ()
	local signal = node._signal
	if signal == nil then
		return
	end

	local index = node._index

	if node._once then
		signal._onceCount -= 1
		node._once = false
	end

	if signal._firingDepth ~= 0 then
		if signal[index] == node then
			signal[index] = nil
			signal._deadCount += 1
		end

		node._signal = nil
		node._callback = nil
		node._index = 0
		node._next = signal._pendingFree
		signal._pendingFree = node
		return
	end

	local last_index = signal._count
	if index ~= last_index then
		local last_node = signal[last_index]
		signal[index] = last_node
		last_node._index = index
	end

	signal[last_index] = nil
	signal._count = last_index - 1

	RecycleConnectionNode(node)
end

local function SignalConnect(self: any, callback: (...any) -> ()): Connection
	local node = connection_pool_head
	if node ~= nil then
		connection_pool_head = node._next
		node._signal = self
		node._callback = callback
		node._once = false
	else
		node = {
			Disconnect = DisconnectNode,
			_signal = self,
			_callback = callback,
			_once = false,
			_index = 0,
			_next = nil,
		}
	end

	local index = self._count + 1
	self._count = index
	node._index = index
	self[index] = node
	return node
end

local function SignalOnce(self: any, callback: (...any) -> ()): Connection
	local node = connection_pool_head
	if node ~= nil then
		connection_pool_head = node._next
		node._signal = self
		node._callback = callback
		node._once = true
	else
		node = {
			Disconnect = DisconnectNode,
			_signal = self,
			_callback = callback,
			_once = true,
			_index = 0,
			_next = nil,
		}
	end

	local index = self._count + 1
	self._count = index
	node._index = index
	self[index] = node
	self._onceCount += 1
	return node
end

local function SignalWait(self: any): ...any
	local waiting_thread = coroutine_running() :: thread

	local wait_thread = self._waitThread
	if wait_thread == nil then
		self._waitThread = waiting_thread
		self._hasWaiters = true
	else
		local waiter = AcquireWaitNode(waiting_thread)
		waiter.next = self._waitHead
		self._waitHead = waiter
	end

	return coroutine_yield()
end

local function SignalFire(self: any, ...: any): ()
	local count = self._count
	if count == 0 then
		if not self._hasWaiters then
			return
		end

		local wait_thread = self._waitThread
		local waiters = self._waitHead
		self._waitThread = nil
		self._waitHead = nil
		self._hasWaiters = false

		if wait_thread ~= nil then
			coroutine_resume(wait_thread, ...)
		end

		while waiters do
			local next_waiter = waiters.next
			coroutine_resume(waiters.thread :: thread, ...)
			RecycleWaitNode(waiters)
			waiters = next_waiter
		end

		return
	end

	local wait_thread = self._waitThread
	local waiters = self._waitHead
	if wait_thread ~= nil or waiters ~= nil then
		self._waitThread = nil
		self._waitHead = nil
		self._hasWaiters = false
	end

	if wait_thread == nil and waiters == nil and count == 1 then
		local node = self[1]
		if node ~= nil then
			local callback = node._callback
			if callback ~= nil then
				if node._once then
					self[1] = nil
					self._count = 0
					self._onceCount = 0
					RecycleConnectionNode(node)
				end
				callback(...)
			end
		end
		return
	end

	self._firingDepth += 1

	if self._onceCount == 0 then
		for index = count, 1, -1 do
			local node = self[index]
			if node ~= nil then
				local callback = node._callback
				callback(...)
			end
		end
	else
		local once_count = self._onceCount
		local dead_count = self._deadCount
		local pending_free = self._pendingFree

		for index = count, 1, -1 do
			local node = self[index]
			if node ~= nil then
				local callback = node._callback
				if node._once then
					once_count -= 1
					self[index] = nil
					dead_count += 1

					node._signal = nil
					node._callback = nil
					node._once = false
					node._index = 0
					node._next = pending_free
					pending_free = node
				end
				callback(...)
			end
		end

		self._onceCount = once_count
		self._deadCount = dead_count
		self._pendingFree = pending_free
	end

	local depth = self._firingDepth - 1
	self._firingDepth = depth
	if depth == 0 then
		if self._deadCount ~= 0 then
			CompactConnections(self)
		end
		if self._pendingFree ~= nil then
			DrainPendingFree(self)
		end
	end

	if wait_thread ~= nil then
		coroutine_resume(wait_thread, ...)
	end

	while waiters do
		local next_waiter = waiters.next
		coroutine_resume(waiters.thread :: thread, ...)
		RecycleWaitNode(waiters)
		waiters = next_waiter
	end
end

local function SignalDisconnectAll(self: any): ()
	local count = self._count
	if count ~= 0 then
		self._onceCount = 0

		if self._firingDepth ~= 0 then
			for index = 1, count do
				local node = self[index]
				if node ~= nil then
					self[index] = nil
					self._deadCount += 1

					node._signal = nil
					node._callback = nil
					node._once = false
					node._index = 0
					node._next = self._pendingFree
					self._pendingFree = node
				end
			end
		else
			local pool_head = connection_pool_head
			for index = 1, count do
				local node = self[index]
				if node ~= nil then
					self[index] = nil
					node._signal = nil
					node._callback = nil
					node._once = false
					node._index = 0
					node._next = pool_head
					pool_head = node
				end
			end
			connection_pool_head = pool_head
			self._count = 0
			self._deadCount = 0

			if self._pendingFree ~= nil then
				DrainPendingFree(self)
			end
		end
	end

	self._waitThread = nil
	self._hasWaiters = false

	local waiter = self._waitHead
	if waiter ~= nil then
		self._waitHead = nil
		while waiter do
			local nextWaiter = waiter.next
			RecycleWaitNode(waiter)
			waiter = nextWaiter
		end
	end
end

local function DestroyedConnect(_self: any, _callback: (...any) -> ()): Connection
	error_local(SIGNAL_DESTROYED_ERROR, 2)
	return nil :: any
end

local function DestroyedOnce(_self: any, _callback: (...any) -> ()): Connection
	error_local(SIGNAL_DESTROYED_ERROR, 2)
	return nil :: any
end

local function DestroyedWait(_self: any): ...any
	error_local(SIGNAL_DESTROYED_ERROR, 2)
	return nil :: any
end

local function DestroyedFire(_self: any, ...: any): ()
	return
end

local function DestroyedDisconnectAll(_self: any): ()
	return
end

local function DestroyedDestroy(_self: any): ()
	return
end

local function SignalDestroy(self: any): ()
	if self.Destroy == DestroyedDestroy then
		return
	end

	self.Connect = DestroyedConnect
	self.Once = DestroyedOnce
	self.Wait = DestroyedWait
	self.Fire = DestroyedFire
	self.DisconnectAll = DestroyedDisconnectAll
	self.Destroy = DestroyedDestroy

	local rbx_connection = self._rbxConnection
	if rbx_connection ~= nil then
		self._rbxConnection = nil
		rbx_connection:Disconnect()
	end

	SignalDisconnectAll(self)
end

local function NewSignal(): Signal
	return {
		Connect = SignalConnect,
		Once = SignalOnce,
		Wait = SignalWait,
		Fire = SignalFire,
		DisconnectAll = SignalDisconnectAll,
		Destroy = SignalDestroy,
		_count = 0,
		_deadCount = 0,
		_onceCount = 0,
		_firingDepth = 0,
		_pendingFree = nil,
		_waitThread = nil,
		_waitHead = nil,
		_hasWaiters = false,
		_rbxConnection = nil,
	} :: any
end

local function WrapSignal(rbxSignal: RBXScriptSignal): Signal
	local signal = NewSignal() :: any
	signal._rbxConnection = rbxSignal:Connect(function(...)
		SignalFire(signal, ...)
	end)
	return signal
end

return table_freeze({
	new = NewSignal,
	wrap = WrapSignal,
})
