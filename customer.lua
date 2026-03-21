local Person = require("person")
local _ = require("product")

--- @class Customer
--- @field person Person
--- @field needs table<ProductType, number>
--- @field needsCollected table<ProductType, number>
local m = {}

function m:update()
	self.person:update()
end

function m:render()
	self.person:render()
end

--- @param world love.World
--- @param x number
--- @param y number
--- @return { body: love.Body, shape: love.CircleShape, fixture: love.Fixture }
function m.newCustomer(world, x, y, needs)
	local person = Person.newPerson(world, x, y)
	person.head.color = { 1, 0, 0, 1 }

	local customer = {
		person = person,
		needs = needs,
		needsCollected = {}
	}

	setmetatable(customer, { __index = m })
	return customer
end

return m
