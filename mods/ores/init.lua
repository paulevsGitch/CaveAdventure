local S = minetest.get_translator("ores")

local sounds = {
	footstep = {name = "stones_default_step", gain = 1.0}
}

local function register_ore(name, description, stone)
	local stone_def = minetest.registered_nodes[stone]
	minetest.register_node("ores:copper_ore", {
		description = S(description),
		drawtype = "mesh",
		mesh = "ores_ore_block.obj",
		tiles = {stone_def.tiles[1], "ores_" .. name .. ".png"},
		sounds = sounds,
		node_hp = (stone_def.node_hp or 3) + 2
	})
end

register_ore("copper_ore", "Copper Ore", "stones:limestone")