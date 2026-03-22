local SceneObject = require("sceneObject")
local Shelf = require("shelf")
local Supply = require("supply")
local CashRegister = require("cashRegister")
local Product = require("product")

---comment
---@param world love.World
---@param virtualWidth number
---@param virtualHeight number
---@return SceneObject[], CashRegister, Shelf[]
local function generateMarketObjects(world, customerManager, virtualWidth, virtualHeight)
	--- @type SceneObject[]
	local marketObjects = {}

	-- Walls
	local screenWidth, screenHeight = virtualWidth, virtualHeight
	local wallThickness = 5
	table.insert(marketObjects,
		SceneObject.newSceneObject(world, 0, 0, { width = wallThickness, height = screenHeight }))
	table.insert(marketObjects, SceneObject.newSceneObject(world, 0, 0, { width = screenWidth, height = wallThickness }))
	table.insert(marketObjects,
		SceneObject.newSceneObject(world, screenWidth - wallThickness, 0,
			{ width = wallThickness, height = screenHeight }))

	local offset = 50
	local halfWallSize = screenWidth / 2

	table.insert(marketObjects,
		SceneObject.newSceneObject(world, 0, screenHeight - wallThickness,
			{ width = halfWallSize, height = wallThickness }))
	local entranceWall = SceneObject.newSceneObject(world, halfWallSize + offset, screenHeight - wallThickness,
		{ width = halfWallSize, height = wallThickness })
	table.insert(marketObjects, entranceWall)

	local doorEntrance = SceneObject.newSceneObject(world, halfWallSize + 2, screenHeight - wallThickness,
		{ width = offset - 2, height = wallThickness }, { type = "dynamic", color = { 0, 0, 0 } })
	local motorJointEntrance = love.physics.newMotorJoint(doorEntrance.body, entranceWall.body, 0.55, false)
	local revolutionJointEntrance = love.physics.newRevoluteJoint(doorEntrance.body, entranceWall.body,
		halfWallSize + offset,
		screenHeight, false)
	revolutionJointEntrance:setLimits(-math.pi * 2 / 3, math.pi * 1 / 2)
	revolutionJointEntrance:setLimitsEnabled(true)
	table.insert(marketObjects, doorEntrance)

	local xPos = 530
	local offset = 50
	local supplyWallSize = math.floor(screenHeight / 2) - offset
	local wallUp = SceneObject.newSceneObject(world, xPos, 0, { width = wallThickness, height = supplyWallSize })
	table.insert(marketObjects, wallUp)
	local wallDown = SceneObject.newSceneObject(world, xPos, supplyWallSize + 2 * offset,
		{ width = wallThickness, height = supplyWallSize * 2 / 5 + 20 })
	table.insert(marketObjects, wallDown)

	table.insert(marketObjects,
		SceneObject.newSceneObject(world, xPos, supplyWallSize + 2 * offset + (supplyWallSize * 2 / 5) + 20,
			{ width = screenWidth - xPos, height = wallThickness }))

	--- door
	local doorDown = SceneObject.newSceneObject(world, xPos, supplyWallSize + offset + 1,
		{ width = wallThickness, height = offset }, { type = "dynamic", color = { 0, 0, 0 } })
	local motorJointDown = love.physics.newMotorJoint(doorDown.body, wallDown.body, 0.55, false)
	local revolutionJointDown = love.physics.newRevoluteJoint(doorDown.body, wallDown.body, xPos,
		supplyWallSize + offset * 2, false)
	revolutionJointDown:setLimits(-math.pi * 2 / 3, math.pi * 1 / 2)
	revolutionJointDown:setLimitsEnabled(true)
	table.insert(marketObjects, doorDown)

	local doorUp = SceneObject.newSceneObject(world, xPos, supplyWallSize, { width = wallThickness, height = offset - 1 },
		{ type = "dynamic", color = { 0, 0, 0 } })
	local motorJointUp = love.physics.newMotorJoint(doorUp.body, wallUp.body, 0.55, false)
	local revolutionJointUp = love.physics.newRevoluteJoint(doorUp.body, wallUp.body, xPos, supplyWallSize, false)
	revolutionJointUp:setLimits(-math.pi / 2, math.pi / 2)
	revolutionJointUp:setLimitsEnabled(true)
	table.insert(marketObjects, doorUp)

	-- Counter
	table.insert(marketObjects,
		SceneObject.newSceneObject(world, 100, 80, { width = 200, height = 40 }, { name = "counter" }))
	-- Cash register
	local cashRegister = CashRegister.newCashRegister(world, 135, 90, { 11, 14, 21, 28, 31, 34, 41, 48, 49, 50, 51 },
		customerManager)
	table.insert(marketObjects, cashRegister)

	table.insert(marketObjects, SceneObject.newSceneObject(world, 100, 115, { width = 180, height = wallThickness }))

	-- Shelves
	local shelves = {
		-- Left
		Shelf.newShelf(world, 80, 230, 100, 50),
		Shelf.newShelf(world, 80, 280, 50, 100),
		Shelf.newShelf(world, 80, 380, 100, 50),
		Shelf.newShelf(world, 130, 280, 50, 100),
		-- Right
		Shelf.newShelf(world, 280, 230, 100, 50),
		Shelf.newShelf(world, 280, 280, 50, 100),
		Shelf.newShelf(world, 280, 380, 100, 50),
		Shelf.newShelf(world, 330, 280, 50, 100),
	}
	shelves[1].accessNodes = { 3, 9, 12, 16 }
	shelves[2].accessNodes = { 4, 5 }
	shelves[3].accessNodes = { 6, 10, 13, 19 }
	shelves[4].accessNodes = { 17, 18 }
	shelves[5].accessNodes = { 23, 29, 32, 36 }
	shelves[6].accessNodes = { 24, 25 }
	shelves[7].accessNodes = { 26, 30, 33, 39 }
	shelves[8].accessNodes = { 37, 38 }

	local count = 0
	local shelfProductList = Product.typeListClone()
	_G.shuffle(shelfProductList)
	_G.forEach(shelves, function(shelf, index)
		if math.floor((index - 1) / Product.typeLength()) > count then
			count = count + 1
			_G.shuffle(shelfProductList)
		end
		shelf.productType = Product.newProduct(shelfProductList[(index % Product.typeLength()) + 1])
		shelf.itemCounter = 1
		table.insert(marketObjects, shelf)
	end)

	-- Supplies
	local supplies = {
		Supply.newSupply(world, 615, 100, 120, 50, Product.newProduct("Soy Milk")),
		Supply.newSupply(world, 615, 150, 120, 50, Product.newProduct("Orange Juice")),
		Supply.newSupply(world, 615, 200, 120, 50, Product.newProduct("Bread")),
		Supply.newSupply(world, 615, 250, 120, 50, Product.newProduct("French Fries")),
		Supply.newSupply(world, 615, 300, 120, 50, Product.newProduct("Banana"))
	}

	forEach(supplies, function(supply)
		table.insert(marketObjects, supply)
	end)

	return marketObjects, cashRegister, shelves
end

return generateMarketObjects
