local index_table = {}
local node_data = {}
local light_data = {}
local array_side_dy
local array_side_dz
local section_count
local density = {}
local layer_cache = {}

local CELL_SIZE = 4

local function init_index_table(emin, emax)
	if #index_table > 0 then
		return
	end

	local side = emax.x - emin.x
	local min_side = 16
	local max_side = side - 16

	array_side_dy = side + 1
	array_side_dz = array_side_dy * array_side_dy
	local size = array_side_dy * array_side_dz

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
			node_data[index] = stone
			if math.random(64) == 1 then
				node_data[index] = stone2
			end
		end
	end
end

local function populate_terrain(vm, emin)
	local roots = minetest.get_content_id("plants:roots")
	local vines = minetest.get_content_id("plants:vines")
	for _, index in ipairs(index_table) do
		if node_data[index] == minetest.CONTENT_AIR and node_data[index + array_side_dy] ~= minetest.CONTENT_AIR and math.random(30) == 1 then
			node_data[index] = roots
			local vine_index = index
			local random_length = math.random(5)
			for i = 1, random_length, 1 do
				vine_index = vine_index - array_side_dy
				if node_data[vine_index] == minetest.CONTENT_AIR then
					node_data[vine_index] = vines
				else
					break
				end
			end
		end
	end
end

--local lake_1 = worldgen.path .. "/schematics/limestone_pool_1.mts"
--local lake_2 = worldgen.path .. "/schematics/limestone_pool_2.mts"
--
--local function populate_terrain(vm, emin)
--	local dec_index
--	local pos = vector.new()
--	for _, index in ipairs(index_table) do
--		if node_data[index] == minetest.CONTENT_AIR and node_data[index - array_side_dy] ~= minetest.CONTENT_AIR and math.random(30) == 1 then
--			dec_index = index - 1
--			pos.x = (dec_index % array_side_dy) + emin.x
--			pos.z = (math.floor(dec_index / array_side_dz)) + emin.z
--			if math.random(4) == 1 then
--				pos.y = (math.floor(dec_index / array_side_dy) % array_side_dy) + emin.y - 2
--				minetest.place_schematic_on_vmanip(vm, pos, lake_1, "0", nil, true, "place_center_x, place_center_z")
--			else
--				pos.y = (math.floor(dec_index / array_side_dy) % array_side_dy) + emin.y - 3
--				minetest.place_schematic_on_vmanip(vm, pos, lake_2, "0", nil, true, "place_center_x, place_center_z")
--			end
--		end
--	end
--end

minetest.register_on_generated(function(minp, maxp, blockseed)
	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	vm:get_data(node_data)
	init_index_table(emin, emax)
	fill_density(emin, emax)
	fill_terrain(emin)
	populate_terrain(vm, emin)
	vm:set_data(node_data)
	-- populate_terrain(vm, emin)
	vm:calc_lighting()
	vm:get_light_data(light_data)
	for index = 1, #light_data do
		light_data[index] = bit.band(light_data[index], 240);
	end
	vm:set_light_data(light_data)
	vm:write_to_map()
	minetest.fix_light(emin, emax)
end)