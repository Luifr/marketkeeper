require("helper")
local Customer = require('customer')
local Product = require("product")

--- @class CustomerManager
--- @field customers Customer[]
--- @field world love.World
--- @field customerSpawnTimer number
local m = {}
m.__index = m

local customerSpawnPosition = {
	x = 450,
	y = 500
}

local maxCustomers = 10
local maxProductsPerCustomer = 1

local maxNeedsTotal = maxCustomers
local maxNeedsPerProduct = math.ceil(maxNeedsTotal / Product.typeLength() * 1.35)

local customerSpawnCheckTime = 6
local chanceToSpawnCustomer = 1

--- @param customerManager CustomerManager
--- @return table<ProductType, number>
--- @return number
local function getAllCustomerNeedsGrouped(customerManager)
	local totalNeedsHash = Product.intoDictionaryZero()
	local totalNeeds = 0

	for _, customer in pairs(customerManager.customers) do
		for _, need in ipairs(customer.needs) do
			local product, quantity = need[1], need[2]
			totalNeeds = totalNeeds + quantity
			totalNeedsHash[product] = (totalNeedsHash[product] or 0) + quantity
		end
	end

	return totalNeedsHash, totalNeeds
end

function m:spawnCustomer()
	local newCustomerNeeds = {}

	local totalNeedsHash, totalNeeds = getAllCustomerNeedsGrouped(self)

	local customerNeedsAmount = math.min(math.random(maxProductsPerCustomer), maxNeedsTotal - totalNeeds)

	local possibleTypes = _G.filter(Product.typeList, function(type)
		if totalNeedsHash[type] and totalNeedsHash[type] > maxNeedsPerProduct then
			return false
		end
		return true
	end)

	for _ = 1, customerNeedsAmount do
		local selectedType = _G.randomArrayItem(possibleTypes)
		table.insert(newCustomerNeeds, { selectedType, 1 })
	end

	local newId = #self.customers + 1
	local newCustomer = Customer.newCustomer(
		self.world,
		newId,
		customerSpawnPosition.x,
		customerSpawnPosition.y,
		newCustomerNeeds
	)

	table.insert(self.customers, newCustomer)
end

local tootooAudio = love.audio.newSource("audio/too-too.flac", "static")

--- @param customerManager CustomerManager
local function onSpawnCustomerTimeout(customerManager)
	print("--> Customer spawn timeout")

	customerManager.customerSpawnTimer = customerSpawnCheckTime

	local _, totalNeeds = getAllCustomerNeedsGrouped(customerManager)
	if tableLen(customerManager.customers) >= maxCustomers then
		print("--> max customers reached")
		return
	end
	if totalNeeds >= maxNeedsTotal then
		print("--> max needs reached")
		return
	end

	local shouldSpawnCustomer = math.random()

	print("--> rand " .. shouldSpawnCustomer)

	if shouldSpawnCustomer <= chanceToSpawnCustomer then
		print("--> Spawn!")
		customerManager:spawnCustomer()
		tootooAudio:play()
	end
end

--- @param dt number
function m:handleCustomerSpawn(dt)
	self.customerSpawnTimer = self.customerSpawnTimer - dt

	if self.customerSpawnTimer <= 0 then
		onSpawnCustomerTimeout(self)
	end
end

--- @param callback fun(customer: Customer, index: integer): nil
function m:forEach(callback)
	_G.forEach(self.customers, callback)
end

function m:render()
	for _, customer in pairs(self.customers) do
		customer:render()
	end
end

function m:cleanup()
	local auxLen = tableLen(self.customers)
	for index, customer in pairs(self.customers) do
		if customer.state.name == "finished" then
			customer.person.head.body:destroy()
			self.customers[index] = nil
		end
	end

	if tableLen(self.customers) < auxLen then
		print(auxLen - tableLen(self.customers)  .." customer(s) is(are) gone")
	end
end

--- @param world love.World
function m.newCustomerManager(world)
	local customerManager = {
		customers = {},
		world = world,
		customerSpawnTimer = customerSpawnCheckTime
	}

	setmetatable(customerManager, m)

	return customerManager
end

return m
