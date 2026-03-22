--- @class TimeoutTimer
--- @field timeoutTime number
--- @field timer number
--- @field show boolean
local m = {}
m.__index = m

local timeToShowTimeout = 2

function m:update(dt)
	self.timer = self.timer + dt
end

function m:isTimedOut()
	return self.timer >= self.timeoutTime
end

function m:resetTimer()
	self.timer = 0
end

--- @param show boolean
function m:setShow(show)
	self.show = show
end

--- @param x number
--- @param y number
function m:render(x, y)
	if not self.show then
		return
	end

	if self.timer < timeToShowTimeout then
		return
	end

	local radius = 12

	love.graphics.push("all")

	love.graphics.setColor({0.5, 0.5, 0.5})
	love.graphics.circle("fill", x, y, radius)

	love.graphics.setColor({0.8, 0.8, 0.8})

	local percentageLeft = math.max((self.timer-timeToShowTimeout) / (self.timeoutTime-timeToShowTimeout), 0)
	local startAngle = - math.pi / 2
	local endAngle = startAngle + (math.pi * 2 * percentageLeft)

	love.graphics.arc("fill", x, y, radius, startAngle, endAngle)

	love.graphics.pop()
end

--- @param timeoutTime number
function m.newTimeoutTimer(timeoutTime)
	local timeoutTimer = setmetatable(
		{
			timeoutTime = timeoutTime,
			timer = 0,
			show = false
		}, m)

	return timeoutTimer
end

return m
