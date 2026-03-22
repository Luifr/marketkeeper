--- @class SceneObject
--- @field body love.Body
--- @field shape love.PolygonShape | love.CircleShape
--- @field fixture love.Fixture
--- @field color [number, number, number, number]
--- @field name string
local m = {}
m.__index = m

function m:update()
end

function m:render()
	love.graphics.push("all")
	love.graphics.setColor(unpack(self.color))
	if self.shape:typeOf("PolygonShape") then
		love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	elseif self.shape:typeOf("CircleShape") then
		local x, y = self.body:getPosition()
		love.graphics.circle("fill", x, y, self.shape:getRadius())
	else
		error("Unknown shape")
	end
	love.graphics.pop()
end

--- @param world love.World
--- @param x number
--- @param y number
--- @param size { radius: number } | { width: number, height: number }
--- @param opts? { type?: love.BodyType, color?: [number, number, number, number], name?: string }
--- @return SceneObject
function m.newSceneObject(world, x, y, size, opts)
	opts = opts or {}
	--- @type love.Body
	local body
	local shape
	if size.height ~= nil and size.width ~= nil then
		body = love.physics.newBody(world, x + size.width / 2, y + size.height / 2, opts.type or "kinematic")
		shape = love.physics.newRectangleShape(size.width, size.height)
	else
		body = love.physics.newBody(world, x, y, opts.type or "kinematic")
		shape = love.physics.newCircleShape(size.radius)
	end
	local fixture = love.physics.newFixture(body, shape)
	fixture:setFriction(0)

	--- @type SceneObject
	local sceneObject = {
		body = body,
		fixture = fixture,
		shape = shape,
		color = opts.color or { 0.5, 0.5, 0.5, 1 },
		name = opts.name
	}

	sceneObject.fixture:setUserData(sceneObject)

	setmetatable(sceneObject, m)

	return sceneObject
end

return m
