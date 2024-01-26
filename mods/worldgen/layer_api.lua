local LAYERS = {};

local DEFAULT_LAYER = {
	min_y = -32000,
	max_y =  32000,
	density_function = function (layer, pos)
		return 1.0;
	end,
	biomes = { "World Border" }
}

-- Layer Def Format
-- min_y, max_y, density_function, biome_function
worldgen.register_layer = function (layer_def)
	table.insert(LAYERS, layer_def)
end

worldgen.get_layer = function (y)
	for _, layer in ipairs(LAYERS) do
		if layer.min_y <= y and layer.max_y >= y then
			return layer
		end
	end
	return DEFAULT_LAYER
end

minetest.register_on_mods_loaded(function()
	local biomes = DEFAULT_LAYER.biomes
	for index, biome in ipairs(biomes) do
		biomes[index] = worldgen.biome_map.get_biome_id(biome)
	end
	
	for _, layer in ipairs(LAYERS) do
		biomes = layer.biomes
		for index, biome in ipairs(biomes) do
			biomes[index] = worldgen.biome_map.get_biome_id(biome)
		end
	end
end)