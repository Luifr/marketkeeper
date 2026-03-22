--- @class Balloon
--- @field image love.Image
local m = {}
m.__index = m


function m:render(x, y)
	local width, height = self.image:getPixelDimensions()
	local spriteScale = 1.1

	width = width * spriteScale
	height = height * spriteScale

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.ellipse("fill", x, y, 30, 15)

	local spriteXPosition = x - width / 2
	local spriteYPosition = y - height / 2

	local offset = 10


	love.graphics.arc("fill", "open", x-30, y+15, -math.pi / 2, -math.pi / 6, 1)

	x = x-40
	y = y+8

	love.graphics.polygon(
		"fill",
		-- p
		x+50,y,
		-- p
		x+offset*2,y,
		-- p3
		x+offset,y+offset*1.5
	)

	love.graphics.draw(self.image, spriteXPosition, spriteYPosition, 0, spriteScale)
end

--- @param image love.Image
function m.newBalloon(image)
	local balloon = setmetatable(
		{
			image = image,
		}, m)

	return balloon
end

return m
