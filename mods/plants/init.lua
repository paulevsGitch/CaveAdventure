local S = minetest.get_translator("plants")

minetest.register_node("plants:roots", {
	description = S("Roots"),
	tiles = {"plants_roots.png"},
    drawtype = "allfaces",
	paramtype = "light",
	node_hp = 0
})