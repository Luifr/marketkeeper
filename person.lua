local SceneObject = require("sceneObject")

--- @class Person
--- @field head SceneObject
--- @field speed number
--- @field groundFriction number
local m = {}

local personRadius = 12
local shoulderRadius = 5
local maxTurningSpeed = 0.1

local forwardIndicatorRadius = 2
local forwardIndicatorDistance = 12

function m:render()
	local x, y = self.head.body:getPosition()

	local forwardAngle = self.head.body:getAngle()
	local shouldersAngle = forwardAngle + (math.pi / 2)
	local shoulderX = math.cos(shouldersAngle) * personRadius
	local shoulderY = math.sin(shouldersAngle) * personRadius

	love.graphics.push("all")
	love.graphics.setColor(0, 1, 0)
	love.graphics.circle("fill", shoulderX + x, shoulderY + y, shoulderRadius)
	love.graphics.circle("fill", -shoulderX + x, -shoulderY + y, shoulderRadius)

	love.graphics.circle("fill", x + math.cos(forwardAngle) * forwardIndicatorDistance,
		y + math.sin(forwardAngle) * forwardIndicatorDistance, forwardIndicatorRadius)
	love.graphics.pop()

	self.head:render()
end

--- @param x number
--- @param y number
function m:moveToDirection(x, y)
	local body = self.head.body
	local length = math.sqrt(x * x + y * y)
	local unitX = x / length
	local unitY = y / length

	body:setLinearVelocity(unitX * self.speed, unitY * self.speed)

	local newAngle = _G.unitVectorToAngle(unitX, unitY)
	body:setAngle(_G.turnTowards(body:getAngle(), newAngle, maxTurningSpeed))
end

function m:friction()
	local vx, vy = self.head.body:getLinearVelocity()
	self.head.body:applyForce(-vx * self.groundFriction, -vy * self.groundFriction)
end

function m:update()
	self:friction()
end

function m:stop()
	self.head.body:setLinearVelocity(0, 0)
end

--- @param world love.World
--- @param x number
--- @param y number
--- @param groundFriction? number
--- @return Person
function m.newPerson(world, x, y, groundFriction)
	local head = SceneObject.newSceneObject(world, x, y, { radius = personRadius, type = "dynamic" })
	head.body:setAngularDamping(10)
	head.color = { 0.7, 0.7, 0.7, 1 }

	head.fixture:setFriction(10)

	local person = {
		head = head,
		speed = 200,
		groundFriction = groundFriction or 1
	}

	setmetatable(person, { __index = m })

	return person
end

return m
