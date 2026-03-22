local SceneObject = require("sceneObject")

--- @class Supply
--- @field sceneObject SceneObject
--- @field productType Product
local m = {}
m.__index = m

function m:update()
end

function m:render()
	self.sceneObject:render()
	local image = self.productType:getSprite()
	local width, height = image:getPixelDimensions()
	local spriteScale = 1.5

	width = width * spriteScale
	height = height * spriteScale
	local topX, topY, bottomX, bottomY = self.sceneObject.fixture:getBoundingBox()

	local spriteXPosition = (topX + bottomX) / 2 - width / 2
	local spriteYPosition = (bottomY + topY) / 2 - height / 2

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(image, spriteXPosition, spriteYPosition, 0, spriteScale)
end

--- @param world love.World
--- @param x number
--- @param y number
--- @param width number
--- @param height number
--- @param product Product
function m.newSupply(world, x, y, width, height, product)
	local supply = setmetatable(
		{
			productType = product,
			sceneObject = SceneObject.newSceneObject(world, x, y,
				{ width = width, height = height })
		}, m)

	supply.sceneObject.fixture:setUserData(supply)

	supply.sceneObject.color = { math.random(), math.random(), math.random(), 1 }

	return supply
end

return m
