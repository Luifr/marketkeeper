local Product = require("product")
local SceneObject = require("sceneObject")

--- @class Shelf
--- @field sceneObject SceneObject
--- @field productType Product
--- @field itemCounter integer
local m = {}

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
	love.graphics.print(self.itemCounter, spriteXPosition + width * 8 / 10, spriteYPosition + height * 2 / 5)
end

--- @param world love.World
--- @param x number
--- @param y number
--- @param width number
--- @param height number
function m.newShelf(world, x, y, width, height)
	local shelf = setmetatable(
		{
			productType = Product.newProduct("Banana"),
			itemCounter = 0,
			sceneObject = SceneObject.newSceneObject(world, x, y,
				{ width = width, height = height })
		}, { __index = m })

	shelf.sceneObject.color = { math.random(), math.random(), math.random(), 1 }

	return shelf
end

return m

