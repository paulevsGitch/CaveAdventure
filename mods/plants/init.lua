local S = minetest.get_translator("plants")

minetest.register_node("plants:roots", {
	description = S("Roots"),
	tiles = {"plants_roots.png"},
    drawtype = "allfaces",
	paramtype = "light",
	node_hp = 0,
	drop = {
		items = {
		    {items = {"plants:root"}, inherit_color = true}
		}
	}
})

minetest.register_node("plants:vines", {
	description = S("Vines"),
	tiles = {"plants_vines.png"},
    drawtype = "plantlike",
	paramtype = "light",
	node_hp = 0,
	drop = {
		items = {
		    {items = {"plants:fiber"}, inherit_color = true}
		}
	}
})

minetest.register_craftitem("plants:root", {
    description = "Root",
    inventory_image = "plants_root.png",
})

minetest.register_craftitem("plants:fiber", {
    description = "Plant Fibers",
    inventory_image = "plants_fiber.png",
})