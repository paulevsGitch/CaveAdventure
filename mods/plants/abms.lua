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
	interval = 10.0,
	chance = 50,
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