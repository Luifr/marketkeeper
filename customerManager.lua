require("helper")
local Customer = require('customer')
local Product = require("product")

--- @class CustomerManager
--- @field customers Customer[]
--- @field world love.World
--- @field customerSpawnTimer number
local m = {}

local customerSpawnPosition = {
	x = 450,
	y = 450
}

local maxCustomers = 6
local maxProductsPerCustomer = 6

local maxNeedsTotal = maxCustomers * maxProductsPerCustomer * 0.85
local maxNeedsPerProduct = maxNeedsTotal / Product.typeLength() * 1.35

local customerSpawnCheckTime = 6
local chanceToSpawnCustomer = 0.2

--- @param customerManager CustomerManager
--- @return table<ProductType, number>
--- @return number
local function getAllCustomerNeedsGrouped(customerManager)
	local totalNeedsHash = Product.intoDictionaryZero()
	local totalNeeds = 0

	for _, customer in pairs(customerManager.customers) do
		for product, quantity in pairs(customer.needs) do
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

	local productTypeCopy = Product.intoDictionary(function(type)
		if totalNeedsHash[type] and totalNeedsHash[type] > maxNeedsPerProduct then
			return nil
		end
		return type
	end)

	local possibleTypes = _G.filter(Product.typeList, function(type)
		if totalNeedsHash[type] and totalNeedsHash[type] > maxNeedsPerProduct then
			return false
		end
		return true
	end)

	for _ = 1, customerNeedsAmount do
		local selectedType = _G.randomArrayItem(possibleTypes)
		newCustomerNeeds[selectedType] = (newCustomerNeeds[selectedType] or 0) + 1
	end

	local newCustomer = Customer.newCustomer(
		self.world,
		customerSpawnPosition.x,
		customerSpawnPosition.y,
		newCustomerNeeds
	)

	table.insert(self.customers, newCustomer)
end

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

--- @param world love.World
function m.newCustomerManager(world)
	local customerManager = {
		customers = {},
		world = world,
		customerSpawnTimer = customerSpawnCheckTime
	}

	setmetatable(customerManager, { __index = m })

	return customerManager
end

return m
