local LAYERS = {};

local DEFAULT_LAYER = {
	min_y = -32000,
	max_y =  32000,
	density_function = function (pos)
		return 1.0;
	end
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