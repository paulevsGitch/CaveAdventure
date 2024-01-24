local S = minetest.get_translator("ores")

local sounds_stone = {
	footstep = {name = "stones_default_step", gain = 1.0},
	dig = {name = "stones_default_step", gain = 0.25},
	dug = {name = "stones_default_step", gain = 0.25},
	place = {name = "stones_default_step", gain = 1.0}
}

local sounds_metal = {
	footstep = {name = "ores_metal_step", gain = 1.0},
	dig = {name = "ores_metal_step", gain = 0.25},
	dug = {name = "ores_metal_step", gain = 0.25},
	place = {name = "ores_metal_step", gain = 1.0}
}

local function place_ore(itemstack, placer, pointed_thing)
	local rotation = math.random(0, 1) * 20 + math.random(0, 1) * 2
	return minetest.item_place_node(itemstack, placer, pointed_thing, rotation)
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
		sounds = sounds_stone,
		node_hp = (stone_def.node_hp or 3) + 2,
		paramtype2 = "facedir",
		on_place = place_ore
	})
end

local function register_variants (node_name, name)
	node_shapes.register_slab(node_name)
	node_shapes.register_stairs(node_name)
	local side = "ores_" .. name .. "_pillar_side.png"
	local top = "ores_" .. name .. "_pillar_top.png"
	node_shapes.register_pillar(node_name, {
		tiles = {top, top, side}
	})
	node_shapes.register_thin_pillar(node_name, {
		tiles = {top, top, side}
	})
end

local function register_metal(name, description, hp)
	local ingot = "ores:" .. name .. "_ingot"
	local block = "ores:" .. name .. "_block"
	local tiles = "ores:" .. name .. "_tiles"
	local small_tiles = "ores:" .. name .. "_small_tiles"

	local image = "ores_" .. name .. "_ingot.png"
	local group = name .. "_ingot_source"

	local groups = {}
	groups[group] = 1

	minetest.register_craftitem(ingot, {
		description = S(description .. " Ingot"),
		inventory_image = image,
		wield_image = image
	})

	minetest.register_node(block, {
		description = S(description .. " Block"),
		tiles = {"ores_" .. name .. "_block.png"},
		groups = groups,
		sounds = sounds_metal,
		node_hp = hp
	})

	minetest.register_node(tiles, {
		description = S(description .. " Tiles"),
		tiles = {"ores_" .. name .. "_tiles.png"},
		groups = groups,
		sounds = sounds_metal,
		node_hp = hp
	})

	minetest.register_node(small_tiles, {
		description = S(description .. " Small Tiles"),
		tiles = {"ores_" .. name .. "_small_tiles.png"},
		groups = groups,
		sounds = sounds_metal,
		node_hp = hp
	})

	node_shapes.register_variants(block)

	node_shapes.register_slab(tiles)
	node_shapes.register_stairs(tiles)

	node_shapes.register_slab(small_tiles)
	node_shapes.register_stairs(small_tiles)

	radial_menu.register_shapes_set({
		block,
		block .. "_slab",
		block .. "_stairs",
		block .. "_pillar",
		block .. "_thin_pillar",
		tiles,
		tiles .. "_slab",
		tiles .. "_stairs",
		small_tiles,
		small_tiles .. "_slab",
		small_tiles .. "_stairs"
	})

	minetest.register_craft({
		output = block,
		recipe = {
			{ ingot, ingot },
			{ ingot, ingot }
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