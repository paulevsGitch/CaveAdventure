worldgen = {}

local path = minetest.get_modpath("worldgen")
worldgen.path = path

worldgen.feature_types = {
	FLOOR = 1,
	VOLUME = 2,
	CEILING = 3
}

dofile(path .. "/biome_map.lua")
dofile(path .. "/layer_api.lua")
dofile(path .. "/layers.lua")
dofile(path .. "/biomes.lua")
dofile(path .. "/generator.lua")
dofile(path .. "/environment.lua")
dofile(path .. "/spawnpoint.lua")