local debug = { name = "stones:debug" }
local pos = vector.zero()

local function debug_feature (context)
	for y = 0, math.random(2, 4) do
		pos.y = y
		context.set_node(pos, debug)
	end
	minetest.debug("Place")
end

worldgen.biome_map.register_biome({
	name = "Limestone Cavern",
	filler = "stones:limestone",
	fog_color = "#898069",
	features = {
		{ feature = debug_feature, count = 1, type = worldgen.feature_types.FLOOR }
	}
})

worldgen.biome_map.register_biome({
	name = "Vine Grouve",
	filler = "stones:limestone",
	surface = "plants:roots_block",
	fog_color = "#8da741",
	features = {
		{ feature = debug_feature, count = 2, type = worldgen.feature_types.FLOOR }
	}
})