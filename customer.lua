local Person = require("person")
local Balloon = require("balloon")
local Product = require("product")
local TimeoutTimer = require("timeoutTimer")

---@alias CustomerID integer

--- @alias CustomerState
--- | { name: "start" }
--- | { name: "Locating Product", productType: ProductType, isWaiting: boolean }
--- | { name: "Fetching Product", shelf: Shelf, path: integer[] }
--- | { name: "Checking Out", hasCheckedOut: boolean, path: integer[] }
--- | { name: "Leaving", path: integer[]}
--- | { name : "finished" }

--- @class Customer
--- @field person Person
--- @field needs [ProductType, integer][]
--- @field state CustomerState
--- @field closestNode integer
--- @field id CustomerID
--- @field balloon Balloon
--- @field timeoutTimer TimeoutTimer
local m = {}
m.__index = m

---@param shelves Shelf[]
---@param map Map
---@param cashRegister CashRegister
function m:update(dt, shelves, map, cashRegister)
	self.person:update()

	if self.state.name == "start" then
		if self.person.itemInHand then
			cashRegister:assignCustomerToQueue(self.id)
			local path = map:path(self.closestNode, { cashRegister:myQueueNode(self.id) })
			self.state = { name = "Checking Out", hasCheckedOut = false, path = path }
			self.timeoutTimer:resetTimer()
			self.timeoutTimer:setShow(true)
		else
			self.state = { name = "Locating Product", productType = self.needs[1][1] }
			self.balloon = Balloon.newBalloon(Product.newProduct(self.needs[1][1]):getSprite())
		end
	elseif self.state.name == "Locating Product" then
		if self.state.isWaiting == true then
			self.timeoutTimer:update(dt)

			if (self.timeoutTimer:isTimedOut()) then
				print("Angry client leaving from waiting by the shelf")

				score:loseLife()

				self.balloon = nil
				self.timeoutTimer:resetTimer()
				self.balloon = Balloon.newBalloon(love.graphics.newImage("sprites/angry-face.png"))
				local path = map:path(self.closestNode, { map.exitNode })
				self.state = { name = "Leaving", path = path }
				return
			end
		end
		for _, shelf in pairs(shelves) do
			if shelf.productType.type == self.state.productType and shelf.itemCounter > 0 then
				local path = map:path(self.closestNode, shelf.accessNodes)
				self.state = { name = "Fetching Product", shelf = shelf, path = path }
				return
			end
		end
		for _, shelf in pairs(shelves) do
			if shelf.productType.type == self.state.productType then
				local path = map:path(self.closestNode, shelf.accessNodes)
				self.state = { name = "Fetching Product", shelf = shelf, path = path }
				return
			end
		end
	elseif self.state.name == "Fetching Product" then
		local targetNode = map.nodes[self.state.path[1]];
		if self.person:moveTowards(targetNode.x, targetNode.y, 20) then
			self.closestNode = self.state.path[1]
			table.remove(self.state.path, 1)
			if #self.state.path == 0 then
				if self.state.shelf.itemCounter > 0 then
					self.person.itemInHand = self.state.shelf.productType
					self.state.shelf.itemCounter = self.state.shelf.itemCounter - 1
					self.state = { name = "start" }
					self.balloon = nil
				else
					self.state = { name = "Locating Product", productType = self.state.shelf.productType.type, isWaiting = true }
					self.timeoutTimer:setShow(true)
				end
			end
		end
	elseif self.state.name == "Checking Out" then
		if self.state.hasCheckedOut then
			self.timeoutTimer:resetTimer()
			self.closestNode = cashRegister.accessNodes[1]
			local path = map:path(self.closestNode, { map.exitNode })
			self.state = { name = "Leaving", path = path }
		else
			if #self.state.path == 0 then
				self.timeoutTimer:update(dt)

				if self.timeoutTimer:isTimedOut() then
					print("Angry client leaving from waiting at the cash register " .. self.id)

					score:loseLife()

					self.timeoutTimer:resetTimer()
					self.person.itemInHand = nil
					self.balloon = Balloon.newBalloon(love.graphics.newImage("sprites/angry-face.png"))
					local path = map:path(self.closestNode, { map.exitNode })
					self.state = { name = "Leaving", path = path }

					cashRegister:removeCustomerFromQueue(self.id)

					return
				end

				local spot = map.nodes[cashRegister:myQueueNode(self.id)]
				if self.person:moveTowards(spot.x, spot.y) then
					local node = cashRegister:myQueueNode(self.id)
					if node then self.closestNode = node end
				end
			else
				local targetNode = map.nodes[self.state.path[1]];
				if self.person:moveTowards(targetNode.x, targetNode.y, 50) then
					self.closestNode = self.state.path[1]
					table.remove(self.state.path, 1)
				end
			end
		end
	elseif self.state.name == "Leaving" then
		local targetNode = map.nodes[self.state.path[1]];
		if self.person:moveTowards(targetNode.x, targetNode.y, 20) then
			self.closestNode = self.state.path[1]
			table.remove(self.state.path, 1)
			if #self.state.path == 0 then
				self.state = { name = "finished" }
			end
		end
	end
end

function m:render()
	self.person:render()

	if self.balloon then
		local x, y = self.person.head.body:getPosition()
		self.balloon:render(x + 40, y - 30)
	end

	if self.timeoutTimer then
		local x, y = self.person.head.body:getPosition()
		self.timeoutTimer:render(x - 30, y - 30)
	end
end

--- @param world love.World
--- @param id CustomerID
--- @param x number
--- @param y number
--- @return { body: love.Body, shape: love.CircleShape, fixture: love.Fixture }
function m.newCustomer(world, id, x, y, needs)
	local person = Person.newPerson(world, x, y)
	person.speed = 75
	person.head.color = { 1, 0, 0, 1 }

	local customer = {
		person = person,
		needs = needs,
		closestNode = 47,
		id = id,
		state = { name = "start" },
		timeoutTimer = TimeoutTimer.newTimeoutTimer(10)
	}

	setmetatable(customer, m)

	person.head.fixture:setUserData(customer)

	return customer
end

return m
