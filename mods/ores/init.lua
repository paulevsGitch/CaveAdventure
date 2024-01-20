local S = minetest.get_translator("ores")

local sounds = {
	footstep = {name = "stones_default_step", gain = 1.0}
}

local function place_ore(itemstack, placer, pointed_thing)
	return minetest.item_place_node(itemstack, placer, pointed_thing, math.random(24))
end

local function register_ore(name, description, stone)
	local stone_def = minetest.registered_nodes[stone]

	local ore_tex = {name = "ores_" .. name .. ".png", backface_culling = true}
	local stone_tex = stone_def.tiles[1]
	if type(stone_tex) == "string" then
		stone_tex = {name = stone_tex, backface_culling = true, align_style="world"}
	end

	minetest.register_node("ores:" .. name, {
		description = S(description),
		drawtype = "mesh",
		mesh = "ores_ore_block.obj",
		tiles = {stone_tex, ore_tex},
		sounds = sounds,
		node_hp = (stone_def.node_hp or 3) + 2,
		paramtype2 = "facedir",
		on_place = place_ore
	})
end

register_ore("copper_ore", "Copper Ore", "stones:limestone")