require('helper')
local CustomerManager = require('customerManager')
local Player = require("player")
local Product = require("product")
local Map = require("map")
local Score = require("score")
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

--- @type Score
local score

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

	score = Score.newScore()
	score:load()
	_G.score = score

	Product.loadSprites()

	marketObjects, cashRegister, shelves = generateMarketObjects(world, customerManager, virtualWidth, virtualHeight)

	map = Map.newMap()
	map:load()

	_G.map = map
end

function love.keypressed(key, scancode, isrepeat)
	if key == "k" then
		deepPrint(customerManager.customers)
	end
	if key == "e" then
		-- Check if player is in fron of something interactive
		player:getObjectCollidingWithRayCast()
	end
	if key == "r" and score.lives <= 0 then
		love.event.quit("restart")
	end
end

function love.update(dt)
	if score.lives <= 0 then
		return
	end

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
    love.graphics.setFont(love.graphics.newFont(16))

	love.graphics.setCanvas(canvas)
	love.graphics.clear()
	love.graphics.push("all")

	_G.forEach(marketObjects, function(obj)
		obj:render()
	end)
	player:render()
	customerManager:render()
	-- map:render()

	score:render(virtualWidth, virtualHeight)

	love.graphics.pop()
	love.graphics.setCanvas()

	local scale = math.min(
		love.graphics.getWidth() / virtualWidth,
		love.graphics.getHeight() / virtualHeight
	)
	love.graphics.draw(canvas, 0, 0, 0, scale, scale)
end
