local SceneObject = require("sceneObject")
local Product = require('product')

--- @class Person
--- @field head SceneObject
--- @field speed number
--- @field groundFriction number
--- @field itemInHand Product | unknown
local m = {}
m.__index = m

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

	if self.itemInHand then
		love.graphics.push("all")
		love.graphics.setColor(1, 1, 1)

		local offsetX = math.cos(forwardAngle) * 15
		local offsetY = math.sin(forwardAngle) * 15

		-- TODO: this maybe a non product item, eg: broom
		local item = self.itemInHand:getSprite()
		local itemWidth, itemHeight = item:getDimensions()
		love.graphics.draw(item, shoulderX + x - itemWidth / 2 + offsetX, shoulderY + y - itemHeight / 2 + offsetY)

		love.graphics.pop()
	end

	love.graphics.circle("fill", x + math.cos(forwardAngle) * forwardIndicatorDistance,
		y + math.sin(forwardAngle) * forwardIndicatorDistance, forwardIndicatorRadius)
	love.graphics.pop()

	self.head:render()
end

---@param scale? number
---@return number
---@return number
function m:forwardVector(scale)
	scale = scale or 1
	local x = math.cos(self.head.body:getAngle())
	local y = math.sin(self.head.body:getAngle())
	return x * scale, y * scale
end

---@param scale? number
---@return number
---@return number
function m:forwardPoint(scale)
	local fx, fy = self:forwardVector(scale)
	local x, y = self.head.body:getPosition()
	return x + fx, y + fy
end

--- @param tx number
--- @param ty number
--- @param reachThreshold? number
--- @return boolean whether they arrived at their destination
function m:moveTowards(tx, ty, reachThreshold)
	local body = self.head.body
	local x, y = self.head.body:getPosition()
	local dx, dy = tx - x, ty - y
	local length = math.sqrt(dx * dx + dy * dy)
	if length < (reachThreshold or 1) then
		body:setLinearVelocity(0, 0)
		return true
	end
	local unitX = dx / length
	local unitY = dy / length

	body:setLinearVelocity(unitX * self.speed, unitY * self.speed)

	local newAngle = _G.unitVectorToAngle(unitX, unitY)
	body:setAngle(_G.turnTowards(body:getAngle(), newAngle, maxTurningSpeed))

	if length < (reachThreshold or 1) then
		return true
	end
	return false
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
	local head = SceneObject.newSceneObject(world, x, y, { radius = personRadius }, { type = "dynamic" })
	head.body:setAngularDamping(10)
	head.color = { 0.7, 0.7, 0.7, 1 }

	head.fixture:setFriction(10)

	local person = {
		head = head,
		speed = 200,
		groundFriction = groundFriction or 1
	}

	setmetatable(person, m)

	head.fixture:setUserData(person)

	return person
end

function m:setItemInHand(item)
	self.itemInHand = item
end

return m
