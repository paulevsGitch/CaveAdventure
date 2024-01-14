local S = minetest.get_translator("stones")

minetest.register_node("stones:limestone", {
	description = S("Limestone"),
	tiles = {"stones_limestone.png"},
	node_hp = 3
})

minetest.register_node("stones:debug", {
	description = S("Debug Light"),
	tiles = {"stones_limestone.png"},
	light_source = minetest.LIGHT_MAX,
	node_hp = 8
})
