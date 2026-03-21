local _G = require("helper")

--- @alias ProductType "Soy Milk" |  "Orange Juice" | "Bread" | "French Fries" | "Banana"
--- @type ProductType[]
local typeList = { "Soy Milk", "Orange Juice", "Bread", "French Fries", "Banana" }

--- @type table<ProductType, love.Image>
local sprites = {}

--- @class Product
--- @field type ProductType
local m = { typeList = typeList }

function m.typeLength()
	return #typeList
end

function m.typeListClone()
	return _G.shallowCopy(typeList)
end

---@param count integer
---@return table
function m.repeatTypeList(count)
	local t = {}
	for _ = 0, count, 1 do
		for _, val in ipairs(typeList) do
			table.insert(t, val)
		end
	end
	return t
end

---@param callback fun(type: ProductType): nil
function m.forEachType(callback)
	_G.forEach(typeList, callback)
end

---@generic T : any
---@param makeValue fun(type: ProductType): T
---@return table<ProductType, T>
function m.intoDictionary(makeValue)
	--- @type table<ProductType, any>
	local dict = {}
	_G.forEach(typeList, function(t)
		dict[t] = makeValue(t)
	end)
	return dict
end

---@return table<ProductType, number>
function m.intoDictionaryZero()
	return m.intoDictionary(function()
		return 0
	end)
end

---@return table<ProductType, nil>
function m.intoDictionaryNil()
	return m.intoDictionary(function()
		return nil
	end)
end

---@return ProductType
function m.randomProductType()
	return typeList[math.random(#typeList)]
end

function m.loadSprites()
	sprites["Banana"] = love.graphics.newImage('sprites/banana.png')
	sprites["Bread"] = love.graphics.newImage("sprites/bread.png")
	sprites["French Fries"] = love.graphics.newImage("sprites/french-fries.png")
	sprites["Orange Juice"] = love.graphics.newImage("sprites/orange-juice.png")
	sprites["Soy Milk"] = love.graphics.newImage("sprites/soy-milk.png")
end

function m:getSprite()
	return sprites[self.type]
end

--- @param type ProductType
function m.newProduct(type)
	local product = setmetatable({}, { __index = m })
	product.type = type
	return product
end

return m
