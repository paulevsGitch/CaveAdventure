local ROOTS_GROWTH = {
	["plants:roots_block"] = {
		["stones:limestone"] = "plants:limestone_with_dense_roots"
	},
	["plants:limestone_with_dense_roots"] = {
		["stones:limestone"] = "plants:limestone_with_roots"
	}
}

local nodenames = {}

for key, _ in pairs(ROOTS_GROWTH) do
	table.insert(nodenames, key)
end

minetest.register_abm({
	label = "Roots Spreading",
	nodenames = nodenames,
	interval = 5.0,
	chance = 5,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local dir = minetest.facedir_to_dir(math.random(0, 5))
		local side_pos = vector.add(pos, dir)
		local side_node = minetest.get_node(side_pos)
		local growth = ROOTS_GROWTH[node.name]
		side_node.name = growth[side_node.name]
		if side_node.name then
			minetest.set_node(side_pos, side_node)
		end
	end,
})

minetest.register_abm({
	label = "Roots Plant Growth",
	nodenames = nodenames,
	interval = 10.0,
	chance = 50,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local axis = math.random(3)
		local place_pos = vector.copy(pos)

		if axis == 1 then
			place_pos.x = place_pos.x + math.random(0, 1) * 2 - 1
		elseif axis == 2 then
			place_pos.y = place_pos.y + math.random(0, 1) * 2 - 1
		else
			place_pos.z = place_pos.z + math.random(0, 1) * 2 - 1
		end

		local world_node = minetest.get_node(place_pos)
		if world_node.name ~= "air" then
			return
		end

		local count = 0
		local count_node
		local count_pos = vector.zero()

		for dx = -2, 2 do
			count_pos.x = pos.x + dx
			for dy = -2, 2 do
				count_pos.y = pos.y + dy
				for dz = -2, 2 do
					count_pos.z = pos.z + dz
					count_node = minetest.get_node(count_pos)
					if count_node.name == "plants:standing_roots" then
						count = count + 1
					end
				end
			end
		end

		if count > 8 then
			return
		end

		world_node.name = "plants:standing_roots"
		world_node.param2 = minetest.dir_to_wallmounted(vector.subtract(pos, place_pos))
		
		minetest.set_node(place_pos, world_node)
	end,
})

minetest.register_abm({
	label = "Tall Grass Roots Growth",
	nodenames = { "plants:roots_block" },
	interval = 10.0,
	chance = 50,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local place_pos = vector.copy(pos)
		place_pos.y = pos.y + 1

		local world_node = minetest.get_node(place_pos)
		if world_node.name ~= "air" then
			return
		end

		local count = 0
		local count_node
		local count_pos = vector.zero()
		count_pos.y = place_pos.y

		for dx = -2, 2 do
			count_pos.x = pos.x + dx
			for dz = -2, 2 do
				count_pos.z = pos.z + dz
				count_node = minetest.get_node(count_pos)
				if count_node.name == "plants:tall_grass" then
					count = count + 1
				end
			end
		end

		if count > 8 then
			return
		end

		world_node.name = "plants:tall_grass"
		world_node.param2 = 2
		
		minetest.set_node(place_pos, world_node)
	end,
})

minetest.register_abm({
	label = "Tall Grass Growth",
	nodenames = { "plants:tall_grass" },
	interval = 10.0,
	chance = 50,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local place_pos = vector.copy(pos)
		place_pos.y = pos.y + 1

		local world_node = minetest.get_node(place_pos)
		if world_node.name ~= "air" then
			return
		end

		local count = 0

		for _ = 1, 5 do
			place_pos.y = place_pos.y - 1
			world_node = minetest.get_node(place_pos)
			if world_node.name == "plants:tall_grass" then
				count = count + 1
			end
		end

		if count == 5 then
			return
		end

		place_pos.y = pos.y + 1
		world_node.name = "plants:tall_grass"
		world_node.param2 = 2
		
		minetest.set_node(place_pos, world_node)
	end,
})