local Person = require("person")

--- @class Player
--- @field person Person
--- @field speed number
local m = {}

function m:update()
	self.person:update()
	local moveX, moveY = 0, 0

	if love.keyboard.isDown("w") then
		moveY = moveY - 1
	end
	if love.keyboard.isDown("s") then
		moveY = moveY + 1
	end
	if love.keyboard.isDown("a") then
		moveX = moveX - 1
	end
	if love.keyboard.isDown("d") then
		moveX = moveX + 1
	end

	if moveX ~= 0 or moveY ~= 0 then
		self.person:moveToDirection(moveX, moveY)
	else
		self.person:stop()
	end
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
	return player
end

return m
