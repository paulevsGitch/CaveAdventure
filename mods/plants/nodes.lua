local S = minetest.get_translator("plants")

local sounds = {
	footstep = {name = "plants_roots_step", gain = 1.0},
	dig = {name = "plants_roots_step", gain = 0.25},
	dug = {name = "plants_roots_step", gain = 0.25},
	place = {name = "plants_roots_step", gain = 0.5}
}

minetest.register_node("plants:flower_stem", {
	description = S("Flower Stem"),
	tiles = { "plants_flower_stem.png" },
	inventory_image = "plants_flower_stem.png",
	wield_image = "plants_flower_stem.png",
    drawtype = "plantlike",
	paramtype = "light",
	node_hp = 0,
	walkable = false,
	selection_box = {
		type = "fixed",
		fixed = { -0.375, -0.5, -0.375, 0.375, 0.5, 0.375 }
	}
})

minetest.register_node("plants:tall_grass", {
	description = S("Tall Grass"),
	tiles = { "plants_tall_grass_2.png" },
	inventory_image = "plants_tall_grass_2.png",
	wield_image = "plants_tall_grass_2.png",
    drawtype = "plantlike",
	paramtype = "light",
	node_hp = 0,
	walkable = false,
	paramtype2 = "meshoptions",
	place_param2 = 2,
	selection_box = {
		type = "fixed",
		fixed = { -0.375, -0.5, -0.375, 0.375, 0.5, 0.375 }
	}
})

minetest.register_node("plants:standing_roots", {
	description = S("Standing Roots"),
	groups = { attached_node = 1 },
	tiles = { "plants_standing_roots.png" },
	inventory_image = "plants_standing_roots.png",
	wield_image = "plants_standing_roots.png",
    drawtype = "plantlike",
	paramtype = "light",
	node_hp = 0,
	drop = "plants:root",
	walkable = false,
	paramtype2 = "wallmounted",
	selection_box = {
		type = "fixed",
		fixed = { -0.375, -0.5, -0.375, 0.375, 0.0, 0.375 }
	}
})

minetest.register_node("plants:limestone_with_roots", {
	description = S("Limestone With Roots"),
	tiles = { "stones_limestone.png^plants_roots_overlay.png" },
	node_hp = 5,
	drop = "stones:limestone",
	sounds = sounds
})

minetest.register_node("plants:limestone_with_dense_roots", {
	description = S("Limestone With Roots"),
	tiles = { "stones_limestone.png^plants_dense_roots_overlay.png" },
	node_hp = 5,
	drop = "stones:limestone",
	sounds = sounds
})

minetest.register_node("plants:roots_block", {
	description = S("Roots Block"),
	tiles = { "plants_roots_block.png" },
	node_hp = 7,
	sounds = sounds
})