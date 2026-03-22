local SceneObject = require("sceneObject")

---@class CashRegister
---@field accessNodes integer[]
---@field sceneObject SceneObject
---@field queue CustomerID[]
---@field customerManager CustomerManager
local m = {}
m.__index = m

function m:render()
	self.sceneObject:render()
end

function m:update()
	self.sceneObject:update()
end

function m:getEndOfQueue()
end

local tchitchiAudio = love.audio.newSource("audio/tuc-ch.flac", "static")

---@return Customer | nil
function m:checkOutFirstCustomer()
	if #self.queue == 0 then
		return
	end
	local customer = self.customerManager.customers[self.queue[1]]
	table.remove(self.queue, 1)
	tchitchiAudio:play()
	customer.state.hasCheckedOut = true
	customer.person.itemInHand = nil
	return customer
end

---@return Customer | nil
function m:firstWaitingCustomer()
	if #self.queue == 0 then
		return
	end
	local customer = self.customerManager.customers[self.queue[1]]
	if #customer.state.path == 0 then
		return customer
	end
	return nil
end

---@param me CustomerID
---@return integer | nil
function m:myQueueNode(me)
	for queueIndex, lineCustomerId in ipairs(self.queue) do
		if lineCustomerId == me then
			return self.accessNodes[queueIndex]
		end
	end
	deepPrint(self.queue, 2)
	error("me not found " .. me)
end

---@param me CustomerID
---@return Customer | nil
function m:customerInFrontOfMe(me)
	for index, lineCustomerId in ipairs(self.queue) do
		if lineCustomerId == me then
			if index == 1 then
				return nil
			else
				return self.customerManager.customers[self.queue[index - 1]]
			end
		end
	end
	error("me not found")
end

---@param customer CustomerID
function m:assignCustomerToQueue(customer)
	table.insert(self.queue, customer)
end

---@param customer CustomerID
function m:removeCustomerFromQueue(customer)
	table.remove(self.queue, customer)
end

---@param world love.World
---@param x number
---@param y number
---@param accessNodes integer[]
---@param customerManager CustomerManager
---@return CashRegister
function m.newCashRegister(world, x, y, accessNodes, customerManager)
	local cashRegister = setmetatable({
		sceneObject = SceneObject.newSceneObject(world, x, y, { height = 20, width = 30 }, { color = { 0.7, 0.7, 0.7 } }),
		accessNodes = accessNodes,
		queue = {},
		customerManager = customerManager,
	}, m)

	cashRegister.sceneObject.fixture:setUserData(cashRegister)

	return cashRegister
end

return m
