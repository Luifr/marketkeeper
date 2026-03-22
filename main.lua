require('helper')
local CustomerManager = require('customerManager')
local Player = require("player")
local Product = require("product")
local Map = require("map")
local generateMarketObjects = require("marketObjects")

--- @type CustomerManager
local customerManager

--- @type Player
local player

--- @type Map
local map

--- @type CashRegister
local cashRegister

--- @type SceneObject[]
local marketObjects = {}

--- @type love.World
local world = love.physics.newWorld(0, 0, true)

--- @type Shelf[]
local shelves = {}

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
	--- @type Player
	_G.player = player

	Product.loadSprites()

	marketObjects, cashRegister, shelves = generateMarketObjects(world, customerManager, virtualWidth, virtualHeight)

	map = Map.newMap()
	map:load()
end

function love.keypressed(key, scancode, isrepeat)
	if key == "k" then
		deepPrint(customerManager.customers)
	end
	if key == "e" then
		-- Check if player is in fron of something interactive
		player:getObjectCollidingWithRayCast()
	end
end

function love.update(dt)
	world:update(dt)

	_G.forEach(marketObjects, function(obj)
		obj:update()
	end)

	customerManager:handleCustomerSpawn(dt)
	customerManager:forEach(function(customer)
		customer:update(dt, shelves, map, cashRegister)
	end)

	customerManager:cleanup()

	player:update()
end

function love.draw()
	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.push("all")


	_G.forEach(marketObjects, function(obj)
		obj:render()
	end)
	player:render()
	customerManager:render()
	-- map:render()

	love.graphics.pop()
	love.graphics.setCanvas()

	local scale = math.min(
		love.graphics.getWidth() / virtualWidth,
		love.graphics.getHeight() / virtualHeight
	)
	love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end
