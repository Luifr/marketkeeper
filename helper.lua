function _G.shallowCopy(t)
	local t2 = {}
	for k, v in pairs(t) do
		t2[k] = v
	end
	return t2
end

function printSpaces(count)
	for _ = 1, count do
		io.write("  ")
	end
end

---@param t any
---@param maxDepth? integer
---@param spacing? integer
function _G.deepPrint(t, maxDepth, spacing)
	local maxDepth = maxDepth or 5
	local spacing = spacing or 0
	if maxDepth == 0 then
		print("[...]")
		return
	end
	if type(t) == "table" then
		print("{")
		for key, value in pairs(t) do
			printSpaces(spacing + 1)
			io.write(tostring(key) .. " = ")
			deepPrint(value, maxDepth - 1, spacing + 1)
		end
		printSpaces(spacing)
		print("}")
	else
		print(tostring(t))
	end
end

function _G.tableLen(t)
	local len = 0
	for _ in pairs(t) do
		len = len + 1
	end

	return len
end

--- @generic T
--- @param table T[]
--- @param callback fun(item: T, index: integer): nil
function _G.forEach(table, callback)
	for index, item in pairs(table) do
		callback(item, index)
	end
end

--- @generic T
--- @param table T[]
--- @return T[]
function _G.shuffle(table)
	for i = #table, 2, -1 do
		local j = math.random(i)
		table[i], table[j] = table[j], table[i]
	end
	return table
end

--- MUST RECEIVE A UNIT VECTOR
--- @param x number
--- @param y number
--- @return number Angle angle the unit vector makes
function _G.unitVectorToAngle(x, y)
	if x < 0 then
		return (math.pi - math.asin(y)) % (math.pi * 2)
	else
		return math.asin(y) % (math.pi * 2)
	end
end

--- @param val number
--- @param min number
--- @param max number
--- @return number
function _G.clamp(val, min, max)
	return math.max(math.min(val, max), min)
end

--- @param currAngle number
--- @param targetAngle number
--- @param turnSpeed number
--- @return number newAngle
function _G.turnTowards(currAngle, targetAngle, turnSpeed)
	local deltaAngle = targetAngle - currAngle
	if deltaAngle > math.pi or deltaAngle < -math.pi then
		deltaAngle = math.pi - deltaAngle
	end
	local clampedDeltaAngle = _G.clamp(deltaAngle, -turnSpeed, turnSpeed)
	return (currAngle + clampedDeltaAngle) % (math.pi * 2)
end

---@generic TFrom : any
---@generic TTo : any
---@param tbl TFrom[]
---@param predicate fun(item: TFrom): boolean, TTo
---@return TTo[]
function _G.mapFilter(tbl, predicate)
	local newTable = {};
	for _, val in ipairs(tbl) do
		local shouldAdd, newVal = predicate(val)
		if shouldAdd then
			table.insert(newTable, newVal)
		end
	end
	return newTable
end

---@generic T : any
---@param tbl T[]
---@param predicate fun(item: T): boolean
---@return T[]
function _G.filter(tbl, predicate)
	local newTable = {};
	for _, val in ipairs(tbl) do
		local shouldAdd = predicate(val)
		if shouldAdd then
			table.insert(newTable, val)
		end
	end
	return newTable
end

---@generic T
---@param tbl T[]
---@return T
function _G.randomArrayItem(tbl)
	return tbl[math.random(#tbl)]
end

---@generic T : any
---@param tbl T[]
---@param predicate fun(item: T): boolean
---@return integer | nil
function _G.findIndex(tbl, predicate)
	for index, val in ipairs(tbl) do
		if predicate(val) then
			return index
		end
	end
	return nil
end

function _G.concat(...)
	local tbls = { ... }
	local finalTbl = {}
	for _, tbl in ipairs(tbls) do
		for _, item in pairs(tbl) do
			table.insert(finalTbl, item)
		end
	end
	deepPrint(finalTbl)
	return finalTbl
end

local timeAtStart = os.time()
function _G.timeSinceStart()
	return os.time() - timeAtStart
end

return _G
