local index_table = {}
local node_data = {}
local param2_data = {}
local light_data = {}
local array_side_dy
local array_side_dz
local section_count
local density = {}
local layer_cache = {}
local place_index = 0
local max_chunk
local gen_side

local CELL_SIZE = 4

local NODE_GET_DATA = { name = "", param2 = 0 }

local FEATURE_CONTEXT = {
	get_node = function(pos)
		local index = place_index + pos.x + pos.y * array_side_dy + pos.z * array_side_dz
		NODE_GET_DATA.name = minetest.get_name_from_content_id(node_data[index])
		NODE_GET_DATA.param2 = param2_data[index]
		return NODE_GET_DATA
	end,
	set_node = function(pos, node)
		local index = place_index + pos.x + pos.y * array_side_dy + pos.z * array_side_dz
		node_data[index] = minetest.get_content_id(node.name)
		param2_data[index] = node.param2 or 0
	end
}

local BIOME_OFFSETS = {
	{x =  0, y =  0, z =  0},
	{x = 15, y =  0, z =  0},
	{x =  0, y = 15, z =  0},
	{x = 15, y = 15, z =  0},
	{x =  0, y =  0, z = 15},
	{x = 15, y =  0, z = 15},
	{x =  0, y = 15, z = 15},
	{x = 15, y = 15, z = 15}
}

local BIOME_LIST = {}
local biome_list_size = 1

local function init_index_table(emin, emax)
	if #index_table > 0 then
		return
	end

	gen_side = emax.x - emin.x
	local min_side = 16
	local max_side = gen_side - 16

	array_side_dy = gen_side + 1
	array_side_dz = array_side_dy * array_side_dy
	local size = array_side_dy * array_side_dz
	max_chunk = math.floor(gen_side / 16) - 1

	index_table = {}

	for index = 1, size do
		local index_dec = index - 1

		local x = index_dec % array_side_dy
		if x < min_side or x > max_side then goto index_end end

		local y = math.floor(index_dec / array_side_dy) % array_side_dy
		if y < min_side or y > max_side then goto index_end end

		local z = math.floor(index_dec / array_side_dz)
		if z < min_side or z > max_side then goto index_end end

		table.insert(index_table, index)

		::index_end::
	end
end

local function fill_density(emin, emax)
	if not section_count then
		local side = emax.x - emin.x + 1
		section_count = math.floor((side - 32) / CELL_SIZE) + 2
	end

	for y = 1, section_count do
		local wy = y * CELL_SIZE + emin.y + 12
		layer_cache[y] = worldgen.get_layer(wy)
	end

	local pos = vector.new()

	for x = 1, section_count do
		pos.x = x * CELL_SIZE + emin.x + 12
		local density_zy = density[x]
		if not density_zy then
			density_zy = {}
			density[x] = density_zy
		end
		for z = 1, section_count do
			pos.z = z * CELL_SIZE + emin.z + 12
			local density_y = density_zy[z]
			if not density_y then
				density_y = {}
				density_zy[z] = density_y
			end
			for y = 1, section_count do
				pos.y = y * CELL_SIZE + emin.y + 12
				density_y[y] = layer_cache[y]:density_function(pos)
			end
		end
	end
end

local function fill_terrain(emin)
	local x, y, z, x1, y1, z1, x2, y2, z2, dx, dy, dz, a, b, c, d, e, f, g, h, dec_index

	local stone = minetest.get_content_id("stones:limestone")
	local stone2 = minetest.get_content_id("stones:debug")

	for _, index in ipairs(index_table) do
		dec_index = index - 1
		x = dec_index % array_side_dy - 16
		y = math.floor(dec_index / array_side_dy) % array_side_dy - 16
		z = math.floor(dec_index / array_side_dz) - 16
		dx = x / CELL_SIZE
		dy = y / CELL_SIZE
		dz = z / CELL_SIZE
		x1 = math.floor(dx)
		y1 = math.floor(dy)
		z1 = math.floor(dz)
		dx = dx - x1
		dy = dy - y1
		dz = dz - z1
		x1 = x1 + 1
		y1 = y1 + 1
		z1 = z1 + 1
		x2 = x1 + 1
		y2 = y1 + 1
		z2 = z1 + 1

		a = density[x1][z1][y1]
		b = density[x2][z1][y1]
		c = density[x1][z2][y1]
		d = density[x2][z2][y1]
		e = density[x1][z1][y2]
		f = density[x2][z1][y2]
		g = density[x1][z2][y2]
		h = density[x2][z2][y2]

		a = math.lerp(a, b, dx)
		b = math.lerp(c, d, dx)
		c = math.lerp(e, f, dx)
		d = math.lerp(g, h, dx)

		a = math.lerp(a, b, dz)
		b = math.lerp(c, d, dz)

		if math.lerp(a, b, dy) > 0 then
			local biome = worldgen.biome_map[index]
			if math.lerp(a, b, dy + 1) <= 0 then
				node_data[index] = biome.surface
			else
				node_data[index] = biome.filler
				if math.random(64) == 1 then
					node_data[index] = stone2
				end
			end
		end
	end
end

local function floor_feature_place(feature, min_x, min_y, min_z, surface)
	local px = math.random(0, 15) + min_x
	local pz = math.random(0, 15) + min_z
	local i_xz = px + pz * array_side_dz
	for py = min_y + 15, min_y, -1 do
		local index = i_xz + py * array_side_dy
		if node_data[index] == surface then
			place_index = index + array_side_dy
			feature(FEATURE_CONTEXT)
		end
	end
end

local function volume_feature_place(feature, min_x, min_y, min_z)
	local px = math.random(0, 15) + min_x
	local py = math.random(0, 15) + min_y
	local pz = math.random(0, 15) + min_z
	place_index = px + py * array_side_dy + pz * array_side_dz
	if node_data[place_index] == minetest.CONTENT_AIR then
		feature(FEATURE_CONTEXT)
	end
end

local function ceiling_feature_place(feature, min_x, min_y, min_z, ceil)
	local px = math.random(0, 15) + min_x
	local pz = math.random(0, 15) + min_z
	local i_xz = px + pz * array_side_dz
	for py = min_y, min_y + 15 do
		local index = i_xz + py * array_side_dy
		if node_data[index] == ceil then
			place_index = index - array_side_dy
			feature(FEATURE_CONTEXT)
		end
	end
end

local function collect_biomes(min_x, min_y, min_z)
	local index = (min_z + 8) * array_side_dz + (min_y + 8) * array_side_dy + min_x + 9
	BIOME_LIST[1] = worldgen.biome_map[index]
	biome_list_size = 1

	for _, offset in ipairs(BIOME_OFFSETS) do
		local x = min_x + offset.x
		local y = min_y + offset.y
		local z = min_z + offset.z

		index = z * array_side_dz + y * array_side_dy + x + 1
		local biome = worldgen.biome_map[index]
		
		for n = 1, biome_list_size do
			if BIOME_LIST[n].id == biome.id then
				goto search_end
			end
		end

		biome_list_size = biome_list_size + 1
		BIOME_LIST[biome_list_size] = biome

		::search_end::
	end
end

local function place_feature(entry, min_x, min_y, min_z, biome)
	if entry.type == worldgen.feature_types.FLOOR then
		floor_feature_place(entry.feature, min_x, min_y, min_z, biome.surface)
	elseif entry.type == worldgen.feature_types.VOLUME then
		volume_feature_place(entry.feature, min_x, min_y, min_z)
	elseif entry.type == worldgen.feature_types.CEILING then
		ceiling_feature_place(entry.feature, min_x, min_y, min_z, biome.filler)
	end
end

local function populate_terrain()
	for cy = 1, max_chunk do
		local min_y = bit.lshift(cy, 4)
		for cx = 1, max_chunk do
			local min_x = bit.lshift(cx, 4)
			for cz = 1, max_chunk do
				local min_z = bit.lshift(cz, 4)
				collect_biomes(min_x, min_y, min_z)
				for n = 1, biome_list_size do
					local biome = BIOME_LIST[n]
					if biome.features then
						for _, entry in ipairs(biome.features) do
							if entry.count < 1 then
								if math.random() < entry.count then
									place_feature(entry, min_x, min_y, min_z, biome)
								end
							else
								for i = 1, entry.count do
									place_feature(entry, min_x, min_y, min_z, biome)
								end
							end
						end
					end
				end
			end
		end
	end
end

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(node_data)
	vm:get_param2_data(param2_data)
	init_index_table(emin, emax)
	worldgen.biome_map.fill_map(emin, gen_side)
	fill_density(emin, emax)
	fill_terrain(emin)
	populate_terrain()
	vm:set_data(node_data)
	vm:set_param2_data(param2_data)
	vm:calc_lighting()
	vm:get_light_data(light_data)
	for index = 1, #light_data do
		light_data[index] = bit.band(light_data[index], 240);
	end
	vm:set_light_data(light_data)
	vm:write_to_map()
	minetest.fix_light(emin, emax)
end)