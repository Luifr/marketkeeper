local Person = require("person")
local Shelf = require("shelf")
local Supply = require("supply")
local CashRegister = require("cashRegister")

--- @class Player
--- @field person Person
--- @field speed number
local m = {}

function m:update()
	self.person:update()
	local moveX, moveY = 0, 0

	if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
		moveY = moveY - 1
	end
	if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
		moveY = moveY + 1
	end
	if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
		moveX = moveX - 1
	end
	if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
		moveX = moveX + 1
	end

	if moveX ~= 0 or moveY ~= 0 then
		local x, y = player.person.head.body:getPosition()
		self.person:moveTowards(x + moveX * 100, y + moveY * 100)
	else
		self.person:stop()
	end
end

local fwoopAudio = love.audio.newSource("audio/fwoop.flac", "static")

--- @param fixture love.Fixture
local function tryInteractWithFixture(fixture, x, y, xn, yn, fraction)
	local fixtureUserData = fixture:getUserData()
	if getmetatable(fixtureUserData) == m or fixtureUserData.name == "counter" then
		return 1
	end

	print("Hit")

	local player = _G.player

	if fixtureUserData then
		if getmetatable(fixtureUserData) == CashRegister then
			print("Cash register")
			--- @cast fixtureUserData CashRegister
			if fixtureUserData:firstWaitingCustomer() ~= nil then
				print("Customer is at cash register")
				fixtureUserData:checkOutFirstCustomer()
			else
				print("No customer at cash register")
			end
		elseif getmetatable(fixtureUserData) == Shelf then
			print("Shelf hit")

			local itemInPlayerHand = player.person.itemInHand

			if not itemInPlayerHand then
				print("player has not item in hand")
				return 0
			end

			local shelfitemLimit = 6

			--- @cast fixtureUserData Shelf
			if fixtureUserData.productType.type == itemInPlayerHand.type then
				print("Shelf has same item")

				if fixtureUserData.itemCounter >= shelfitemLimit then
					print("Shelf is already full")
					return 0
				end

				_G.player.person.itemInHand = nil
				fixtureUserData.itemCounter = fixtureUserData.itemCounter + 1
				fwoopAudio:play()
			else
				print("Shelf has wrong item")
			end
		elseif getmetatable(fixtureUserData) == Supply then
			print("Supply")

			fwoopAudio:play()
			--- @cast fixtureUserData Supply
			player.person.itemInHand = fixtureUserData.productType
		end
	end

	return 0
end

function m:getObjectCollidingWithRayCast()
	local rayCastLength = 30
	local x, y = self.person.head.body:getPosition()
	local forwardAngle = self.person.head.body:getAngle()
	local rayCastX = math.cos(forwardAngle) * rayCastLength
	local rayCastY = math.sin(forwardAngle) * rayCastLength

	local world = self.person.head.body:getWorld()

	world:rayCast(x, y, rayCastX + x, rayCastY + y, tryInteractWithFixture)
end

function m:render()
	self.person:render()
end

--- @param world love.World
--- @param x number
--- @param y number
--- @return Player
function m.newPlayer(world, x, y)
	local person = Person.newPerson(world, x, y, 0)

	local player = {
		person = person,
	}

	setmetatable(player, { __index = m })

	person.head.fixture:setUserData(player)

	return player
end

return m
