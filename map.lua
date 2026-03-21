---@class Map
local m

---@param x number
---@param y number
---@return any Set a better type later
function m:getAt(self, x, y)
	return self[y][x]
end

---@param x number
---@param y number
---@param val any set better type later
function m:setAt(self, x, y, val)
	self[y][x] = val
end

---@param callback fun(cell: any, x: number, y: number): any
function m:forEach(self, callback)
	for y, row in self do
		for x, cell in row do
			callback(cell, x, y)
		end
	end
end

function m.newMap()
	--  |-----------/
	--  |    =   o  |
	--  | ---|  --- |
	--  |           |
	--  |  |-| |-|  =
	--  |  |-| |-|  |
	--  |           |
	--  |-----------|
	local map = {
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
		{ nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, },
	}
	setmetatable(map, m)
	return map
end

return m
