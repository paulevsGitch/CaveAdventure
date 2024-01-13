local S = minetest.get_translator("stones")

minetest.register_node("stones:limestone", {
	description = S("Limestone"),
	tiles = {"stones_limestone.png"}
})

minetest.register_node("stones:debug", {
	description = S("Debug Light"),
	tiles = {"stones_limestone.png"},
	light_source = minetest.LIGHT_MAX
})
