--- @class SceneObject
--- @field body love.Body
--- @field shape love.PolygonShape | love.CircleShape
--- @field fixture love.Fixture
--- @field color [number, number, number, number]
local m = {}

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
--- @param opts { width: number, height: number, type?: love.BodyType, color?: [number, number, number, number] } | { radius: number, type?: love.BodyType, color?: [number, number, number, number] }
--- @return SceneObject
function m.newSceneObject(world, x, y, opts)
	--- @type love.Body
	local body
	local shape
	if opts.height ~= nil and opts.width ~= nil then
		body = love.physics.newBody(world, x + opts.width / 2, y + opts.height / 2, opts.type or "kinematic")
		shape = love.physics.newRectangleShape(opts.width, opts.height)
	else
		body = love.physics.newBody(world, x, y, opts.type or "kinematic")
		shape = love.physics.newCircleShape(opts.radius)
	end
	local fixture = love.physics.newFixture(body, shape)

	--- @type SceneObject
	local sceneObject = {
		body = body,
		fixture = fixture,
		shape = shape,
		color = opts.color or { 0.5, 0.5, 0.5, 1 }
	}

	setmetatable(sceneObject, { __index = m })

	return sceneObject
end

return m
