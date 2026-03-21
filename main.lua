require('helper')
local CustomerManager = require('customerManager')
local Player = require("player")
local Product = require("product")
local SceneObject = require("sceneObject")
local Shelf = require("shelf")

--- @type CustomerManager
local customerManager

--- @type Player
local player

--- @type love.World
local world = love.physics.newWorld(0, 0, true)

--- @type SceneObject[]
local marketObjects = {}

--- @type love.Canvas
local canvas

local virtualWidth
local virtualHeight

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	love.physics.setMeter(64)
	love.graphics.setBackgroundColor(230 / 255, 227 / 255, 197 / 255)

	math.randomseed(os.time())

	virtualWidth = 854
	virtualHeight = 480
	canvas = love.graphics.newCanvas(virtualWidth, virtualHeight)

	customerManager = CustomerManager.newCustomerManager(world)
	player = Player.newPlayer(world, 50, 50)

	Product.loadSprites()

	-- Walls
	local screenWidth, screenHeight = virtualWidth, virtualHeight
	local wallThickness = 5
	table.insert(marketObjects,
		SceneObject.newSceneObject(world, 0, 0, { width = wallThickness, height = screenHeight }))
	table.insert(marketObjects, SceneObject.newSceneObject(world, 0, 0, { width = screenWidth, height = wallThickness }))
	table.insert(marketObjects,
		SceneObject.newSceneObject(world, screenWidth - wallThickness, 0,
			{ width = wallThickness, height = screenHeight }))
	table.insert(marketObjects,
		SceneObject.newSceneObject(world, 0, screenHeight - wallThickness,
			{ width = screenWidth, height = wallThickness }))

	-- Counter
	table.insert(marketObjects, SceneObject.newSceneObject(world, 100, 80, { width = 200, height = 40 }))
	-- Cash register
	table.insert(marketObjects,
		SceneObject.newSceneObject(world, 150, 90, { width = 30, height = 20, color = { 0.7, 0.7, 0.7 } }))

	-- Shelves
	local shelves = {
		-- Left
		Shelf.newShelf(world, 80, 180, 100, 50),
		Shelf.newShelf(world, 80, 230, 50, 150),
		Shelf.newShelf(world, 80, 380, 100, 50),
		Shelf.newShelf(world, 130, 230, 50, 150),
		-- Right
		Shelf.newShelf(world, 280, 180, 100, 50),
		Shelf.newShelf(world, 280, 230, 50, 150),
		Shelf.newShelf(world, 280, 380, 100, 50),
		Shelf.newShelf(world, 330, 230, 50, 150),
	}

	local count = 0
	local shelfProductList = Product.typeListClone()
	_G.shuffle(shelfProductList)
	_G.forEach(shelves, function(shelf, index)
		if math.floor((index - 1) / Product.typeLength()) > count then
			count = count + 1
			_G.shuffle(shelfProductList)
		end
		shelf.productType = Product.newProduct(shelfProductList[(index % Product.typeLength()) + 1])
		table.insert(marketObjects, shelf)
	end)

	-- backroom
	table.insert(marketObjects, SceneObject.newSceneObject(world, 600, 100, { width = 200, height = 300 }))

	local points = {
		{ x = 50,  y = 150 },
		{ x = 50,  y = 200 },
		{ x = 50,  y = 250 },
		{ x = 50,  y = 300 },
		{ x = 50,  y = 350 },
		{ x = 50,  y = 400 },
		{ x = 50,  y = 450 },
		{ x = 100, y = 150 },
		{ x = 100, y = 450 },
		{ x = 150, y = 150 },
		{ x = 150, y = 450 },
		{ x = 200, y = 150 },
		{ x = 200, y = 200 },
		{ x = 200, y = 250 },
		{ x = 200, y = 300 },
		{ x = 200, y = 350 },
		{ x = 200, y = 400 },
		{ x = 200, y = 450 },
		{ x = 250, y = 150 },
		{ x = 250, y = 200 },
		{ x = 250, y = 250 },
		{ x = 250, y = 300 },
		{ x = 250, y = 350 },
		{ x = 250, y = 400 },
		{ x = 250, y = 450 },
		{ x = 300, y = 150 },
		{ x = 300, y = 450 },
		{ x = 350, y = 150 },
		{ x = 350, y = 450 },
		{ x = 400, y = 150 },
		{ x = 400, y = 200 },
		{ x = 400, y = 250 },
		{ x = 400, y = 300 },
		{ x = 400, y = 350 },
		{ x = 400, y = 400 },
		{ x = 400, y = 450 },
		{ x = 450, y = 150 },
		{ x = 450, y = 200 },
		{ x = 450, y = 250 },
		{ x = 450, y = 300 },
		{ x = 450, y = 350 },
		{ x = 450, y = 400 },
		{ x = 450, y = 450 },
		{ x = 500, y = 150 },
		{ x = 500, y = 200 },
		{ x = 500, y = 250 },
		{ x = 500, y = 300 },
		{ x = 500, y = 350 },
		{ x = 500, y = 400 },
		{ x = 500, y = 450 }
	}

	-- for _, point in pairs(points) do
	-- 	table.insert(marketObjects, SceneObject.newSceneObject(world, point.x, point.y, { width = 10, height = 10 }))
	-- end
end

function love.update(dt)
	world:update(dt)

	_G.forEach(marketObjects, function(obj)
		obj:update()
	end)

	customerManager:handleCustomerSpawn(dt)
	customerManager:forEach(function(customer)
		customer:update()
	end)

	player:update()
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()

	_G.forEach(marketObjects, function(obj)
		obj:render()
	end)

	player:render()

	customerManager:render()

	love.graphics.setCanvas()

	local scale = math.min(
		love.graphics.getWidth() / virtualWidth,
		love.graphics.getHeight() / virtualHeight
	)
	love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end
