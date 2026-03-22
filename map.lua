---@class Node
---@field x number
---@field y number
---@field neighbours integer[]
local Node = {}
Node.__index = Node

function Node.newNode(x, y)
	local node = setmetatable({ x = x, y = y, neighbours = {} }, Node)
	return node
end

---@class Map
---@field exitNode integer
---@field nodes Node[]
local m = {}
m.__index = m

local nodeRadius = 5

---@param x number
---@param y number
---@return any Set a better type later
function m:getAt(x, y)
	return self[y][x]
end

---@param x number
---@param y number
---@param val any set better type later
function m:setAt(x, y, val)
	self[y][x] = val
end

function m:load()
	---@type ({ x: number, y: number, actualIndex: number } | boolean)[][]
	local points = {
		{ { 50, 150 },  { 50, 200 },  { 50, 250 },  { 50, 300 },  { 50, 350 },  { 50, 400 },  { 50, 450 } },
		{ { 100, 150 }, { 100, 200 }, false,        false,        false,        false,        { 100, 450 } },
		{ { 150, 150 }, { 150, 200 }, false,        false,        false,        false,        { 150, 450 } },
		{ { 200, 150 }, { 200, 200 }, { 200, 250 }, { 200, 300 }, { 200, 350 }, { 200, 400 }, { 200, 450 } },
		{ { 250, 150 }, { 250, 200 }, { 250, 250 }, { 250, 300 }, { 250, 350 }, { 250, 400 }, { 250, 450 } },
		{ { 300, 150 }, { 300, 200 }, false,        false,        false,        false,        { 300, 450 } },
		{ { 350, 150 }, { 350, 200 }, false,        false,        false,        false,        { 350, 450 } },
		{ { 400, 150 }, { 400, 200 }, { 400, 250 }, { 400, 300 }, { 400, 350 }, { 400, 400 }, { 400, 450 } },
		{ { 450, 150 }, { 450, 200 }, { 450, 250 }, { 450, 300 }, { 450, 350 }, { 450, 400 }, { 450, 450 } },
		{ { 500, 150 }, { 500, 200 }, { 500, 250 }, { 500, 300 }, { 500, 350 }, { 500, 400 }, { 500, 450 } },
	}

	local actualIndex = 1
	for x, column in ipairs(points) do
		for y, point in ipairs(column) do
			if point ~= false then
				point.actualIndex = actualIndex
				actualIndex = actualIndex + 1
			end
		end
	end


	for x, column in ipairs(points) do
		for y, point in ipairs(column) do
			if point ~= false then
				local newNode = Node.newNode(point[1], point[2])
				table.insert(self.nodes, newNode)
				local currentIndex = #self.nodes

				if x - 1 >= 1 and points[x - 1][y] ~= false then
					local leftIndex = points[x - 1][y].actualIndex
					table.insert(newNode.neighbours, leftIndex)
					table.insert(self.nodes[leftIndex].neighbours, currentIndex)
				end
				if y - 1 >= 1 and points[x][y - 1] ~= false then
					local topIndex = points[x][y - 1].actualIndex
					table.insert(newNode.neighbours, topIndex)
					table.insert(self.nodes[topIndex].neighbours, currentIndex)
				end
			end
		end
	end

	local spawnNode = Node.newNode(450, 500)
	table.insert(spawnNode.neighbours, 47)
	table.insert(self.nodes, spawnNode)

	table.insert(self.nodes[47].neighbours, #self.nodes)

	self.exitNode = #self.nodes
end

function m:render()
	_G.forEach(self.nodes, function(node, index)
		love.graphics.setColor(1, 1, 0, 1)
		love.graphics.circle("fill", node.x, node.y, nodeRadius)
		for _, neighbourIndex in ipairs(node.neighbours) do
			local neighbour = self.nodes[neighbourIndex]
			love.graphics.line(node.x, node.y, neighbour.x, neighbour.y)
		end
		love.graphics.setColor(0, 1, 1, 1)
		love.graphics.print(tostring(index), node.x, node.y)
	end)
end

---@param start integer
---@param  possibleDestinations integer[]
---@return integer[]
function m:path(start, possibleDestinations)
	local Astar = require("astar.astar")
	local map = self
	local camp = {}
	function camp:get_neighbors(nodeIndex, fromNode, add_neighbor_cb, userdata)
		for _, neighbourIndex in ipairs(map.nodes[nodeIndex].neighbours) do
			add_neighbor_cb(neighbourIndex)
		end
	end

	-- Cost of two adjacent nodes.
	-- Distance, distance + cost or other comparison value you want
	function camp:get_cost(fromNodeIndex, toNodeIndex, userdata)
		local fromNode = map.nodes[fromNodeIndex]
		local toNode = map.nodes[toNodeIndex]
		return math.sqrt(math.pow(fromNode.x - toNode.x, 2) + math.pow(fromNode.y - toNode.y, 2))
	end

	-- For heuristic. Estimate cost of current node to goal node
	-- As close to the real cost as possible
	function camp:estimate_cost(nodeIndex, goalNodeIndex, userdata)
		local node = map.nodes[nodeIndex]
		local goalNode = map.nodes[goalNodeIndex]
		return math.sqrt(math.pow(node.x - goalNode.x, 2) + math.pow(node.y - goalNode.y, 2))
	end

	local closestDestination
	for _, destination in ipairs(possibleDestinations) do
		if closestDestination == nil or camp:estimate_cost(start, closestDestination) > camp:estimate_cost(start, destination) then
			closestDestination = destination
		end
	end

	local finder = Astar.new(camp)
	return finder:find(start, closestDestination)
end

function m.newMap()
	local map = setmetatable({ nodes = {}, exitNode = nil }, m)


	return map
end

return m
