--- @class Score
--- @field lives number
--- @field money number
--- @field heartImage love.Image
--- @field brokenHeartImage love.Image
--- @field moneyImage love.Image
--- @field previousHighScore number | nil
local m = {}
m.__index = m

local initialLives = 3
local saveFilePath = "marketkeeper.txt"

---@param virtualWidth number
---@param virtualHeight number
function m:render(virtualWidth, virtualHeight)
    love.graphics.setFont(love.graphics.newFont(50))

    local moneyWidth, moneyHeight = self.moneyImage:getDimensions()
    local heartWidth, _ = self.heartImage:getDimensions()
    love.graphics.draw(self.moneyImage, virtualWidth - 320, 10, 0, 2)
    love.graphics.print(self.money, virtualWidth - 300 + moneyWidth, moneyHeight / 2)

    for i = 1, initialLives do
        local imageToRender
        if i <= self.lives then
            imageToRender = self.heartImage
        else
            imageToRender = self.brokenHeartImage
        end
        love.graphics.draw(imageToRender, virtualWidth - 200 + ((i - 1) * heartWidth), 30)
    end

    if self.lives <= 0 then

        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 50, 80, 750, 350)
        love.graphics.setColor(1, 1, 1)
        local heightMiddle = virtualHeight / 2
        love.graphics.printf("Game over! You served " .. self.money .. " customers\nPress R to restart", 0, heightMiddle - 125, virtualWidth, "center")

        local highScoreText
        if not self.previousHighScore then
            highScoreText = "New highscore!"
        else
            if self.previousHighScore and self.money > self.previousHighScore then
                highScoreText = "New highscore! Previous high score was " .. self.previousHighScore
            else
                if self.previousHighScore and self.previousHighScore >= self.money then
                    highScoreText = "Current highscore is " .. self.previousHighScore
                end

            end

        end

        if highScoreText then
            love.graphics.printf(highScoreText, 0, heightMiddle + 60, virtualWidth, "center")
        end
    end
end

function m:load()
    self.heartImage = love.graphics.newImage("sprites/heart.png")
    self.brokenHeartImage = love.graphics.newImage("sprites/broken-heart.png")
    self.moneyImage = love.graphics.newImage("sprites/money.png")

    if love.filesystem.getInfo(saveFilePath) then
        local contents = love.filesystem.read(saveFilePath)
        self.previousHighScore = tonumber(contents) or nil
    end
end

function m:increaseScore()
    self.money = self.money + 1
end

function m:loseLife()
    if self.lives <= 0 then
        print("Cant lose more lives")
    else
        self.lives = self.lives - 1
        if self.lives <= 0 then
            print("Game over!")
            if (self.money > self.previousHighScore) then
                -- save high score
                love.filesystem.write(saveFilePath, tostring(self.money))
            end
        end
    end
end

function m.newScore()
    local score = setmetatable(
        {
            money = 0,
            lives = initialLives
        }, m)

    return score
end

return m
