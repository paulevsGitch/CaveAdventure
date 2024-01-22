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

local function register_metal(name, description, hp)
	local ingot = "ores:" .. name .. "_ingot"
	local block = "ores:" .. name .. "_block"
	local tiles = "ores:" .. name .. "_tiles"

	local image = "ores_" .. name .. "_ingot.png"
	local group = name .. "_ingot_source"

	local groups = {}
	groups[group] = 1

	minetest.register_craftitem(ingot, {
		description = S(description .. " Ingot"),
		inventory_image = image,
		wield_image = image
	})

	minetest.register_node(tiles, {
		description = S(description .. " Tiles"),
		tiles = {"ores_" .. name .. "_tiles.png"},
		groups = groups,
		sounds = sounds,
		node_hp = hp
	})

	minetest.register_node(block, {
		description = S(description .. " Block"),
		tiles = {"ores_" .. name .. "_block.png"},
		groups = groups,
		sounds = sounds,
		node_hp = hp
	})

	minetest.register_craft({
		output = block,
		recipe = {
			{ ingot, ingot },
			{ ingot, ingot }
		},
	})

	minetest.register_craft({
		output = tiles .. " 4",
		recipe = {
			{ block, block },
			{ block, block }
		},
	})

	minetest.register_craft({
		output = ingot .. " 4",
		type = "shapeless",
		recipe = { "group:" .. group },
	})
end

register_ore("coal_ore", "Coal Ore", "stones:limestone")
register_ore("copper_ore", "Copper Ore", "stones:limestone")

register_metal("copper", "Copper")