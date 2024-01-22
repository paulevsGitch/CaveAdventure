-- Add this function to node def table:
-- on_neighbour_update(pos)

-- Function will be applied when one of node neighbours will be updated (by player or recursively)
-- pos is the current node position
-- Returns true if node was updated, false/nothing if not

local OFFSETS = {
	vector.new(0, 1, 0),
	vector.new(0, 0, 1),
	vector.new(0, 0, -1),
	vector.new(1, 0, 0),
	vector.new(-1, 0, 0),
	vector.new(0, -1, 0)
}

-- Depth added to prevent infinity recursion

local function check_neighbours(pos, depth)
	local pos2 = vector.zero()
	for i = 1, 6 do
		local offset = OFFSETS[i]
		pos2.x = pos.x + offset.x
		pos2.y = pos.y + offset.y
		pos2.z = pos.z + offset.z
		local node_name = minetest.get_node(pos2).name
		local def = minetest.registered_nodes[node_name]
		if def and def.on_neighbour_update then
			if def.on_neighbour_update(pos2) and depth > 0 then
				check_neighbours(pos2, depth - 1)
			end
		end
	end
end

local function check_neighbours_iterative(pos)
	check_neighbours(pos, 16)
end

minetest.register_on_placenode(check_neighbours_iterative)
minetest.register_on_dignode(check_neighbours_iterative)