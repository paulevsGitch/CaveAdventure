local S = minetest.get_translator("stones")

local sounds = {
	footstep = {name = "stones_default_step", gain = 1.0},
	dig = {name = "stones_default_step", gain = 0.25},
	dug = {name = "stones_default_step", gain = 0.25},
	place = {name = "stones_default_step", gain = 0.5}
}

local function register_stone_set(name, description)
	local block = "stones:" .. name
	local big_tile = "stones:" .. name .. "_big_tile"
	local tiles = "stones:" .. name .. "tiles"

	minetest.register_node(block, {
		description = S(description),
		tiles = {"stones_" .. name .. ".png"},
		sounds = sounds,
		node_hp = 3
	})

	minetest.register_node(big_tile, {
		description = S(description .. " Big Tile"),
		tiles = {"stones_" .. name .. "_big_tile.png"},
		sounds = sounds,
		node_hp = 3
	})

	minetest.register_node(tiles, {
		description = S(description .. " Tiles"),
		tiles = {"stones_" .. name .. "_tiles.png"},
		sounds = sounds,
		node_hp = 3
	})

	node_shapes.register_variants(block)

	node_shapes.register_slab(big_tile)
	node_shapes.register_stairs(big_tile)

	node_shapes.register_slab(tiles)
	node_shapes.register_stairs(tiles)

	radial_menu.register_shapes_set({
		block,
		block .. "_slab",
		block .. "_stairs",
		block .. "_pillar",
		block .. "_thin_pillar",
		big_tile,
		big_tile .. "_slab",
		big_tile .. "_stairs",
		tiles .. "_slab",
		tiles .. "_stairs"
	})
end

register_stone_set("limestone", "Limestone")

minetest.register_node("stones:debug", {
	description = S("Debug Light"),
	tiles = {"stones_debug.png"},
	light_source = minetest.LIGHT_MAX,
	sounds = sounds,
	node_hp = 8
})

local function place_dripstone(itemstack, placer, pointed_thing)
	local dir = pointed_thing.under.y - pointed_thing.above.y
	if dir == 0 then return itemstack end

	local param2 = math.random(0, 3)
	if dir > 0 then param2 = param2 + 20 end

	local pos = vector.copy(pointed_thing.above)
	local count = 0

	for _ = 1, 3 do
		pos.y = pos.y + dir
		local node = minetest.get_node(pos)
		if minetest.get_item_group(node.name, "dripstone") > 0 then
			count = count + 1
		end
	end

	if count > 2 then
		return itemstack
	end

	pos.y = pointed_thing.above.y

	for _ = 1, 3 do
		pos.y = pos.y + dir
		local node = minetest.get_node(pos)

		if minetest.get_item_group(node.name, "dripstone") == 0 then
			goto search_end
		end

		local axis = math.floor(node.param2 / 20)
		local node_dir = axis * 2 - 1

		if node_dir ~= dir then
			goto search_end
		end

		local index = tonumber(node.name:sub(-1))

		if index < 3 then
			node.name = node.name:sub(1, -2) .. (index + 1)
			minetest.set_node(pos, node)
		end
	end

	::search_end::

	return minetest.item_place_node(itemstack, placer, pointed_thing, param2)
end

local function update_dripstone (pos)
	local node = minetest.get_node(pos)
	local axis = math.facedir_axis(node.param2)
	local pos2 = vector.subtract(pos, axis)
	local node_def = minetest.registered_nodes[minetest.get_node(pos2).name]
	if not node_def or not node_def.walkable or not (node_def.groups and node_def.groups.dripstone ~= 0) then
		minetest.dig_node(pos) -- will update recursively on its own
	end
end

for i = 1, 3 do
	local side = 0.125 + (i - 1) * 0.125

	local box = {
		type = "fixed",
		fixed = { -side, -0.5, -side, side, 0.5, side }
	}

	local groups = {dripstone = 1}
	if i > 1 then
		groups.not_in_creative_inventory = 1
	end

	minetest.register_node("stones:dripstone_" .. i, {
		description = S("Dripstone"),
		groups = groups,
		tiles = {"stones_limestone.png"},
		drawtype = "mesh",
		mesh = "stones_dripstone_" .. i .. ".obj",
		sounds = sounds,
		node_hp = 1,
		paramtype = "light",
		paramtype2 = "facedir",
		selection_box = box,
		collision_box = box,
		on_place = place_dripstone,
		drop = "stones:dripstone_1",
		on_neighbour_update = update_dripstone
	})
end