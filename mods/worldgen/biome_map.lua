local SEED = minetest.get_mapgen_setting("seed")
local BIOME_SIZE = 64
local BIOMES = {}
local ID_BY_NAME = {}
local DATA = {}

worldgen.biome_map = {}

worldgen.biome_map.get_biome_id = function(name)
	return ID_BY_NAME[name]
end

local params = {
	offset = 0,
	scale = 1,
	spread = {x = 1, y = 1, z = 1},
	octaves = 3,
	persistence = 0.5,
	lacunarity = 2.0,
	flags = "defaults"
}

math.randomseed(SEED)
local seed_x = math.random(0, 65535)
local seed_y = math.random(0, 65535)
local seed_z = math.random(0, 65535)

params.seed = seed_x
local DISTORT_X_NOISE = PerlinNoise(params)
params.seed = seed_y
local DISTORT_Y_NOISE = PerlinNoise(params)
params.seed = seed_z
local DISTORT_Z_NOISE = PerlinNoise(params)

worldgen.biome_map.register_biome = function(def)
	def.id = #BIOMES + 1
	table.insert(BIOMES, def)
	ID_BY_NAME[def.name] = def.id
end

local path = minetest.get_worldpath()

local function save_chunk(chunk, cx, cy, cz)
	local data = ""

	for i = 1, 4096 do
		data = data .. string.char(chunk[i].id)
	end

	minetest.mkdir(path .. "/worldgen")
	local file = io.open(path .. "/worldgen/biome_chunk_" .. cx .. "_" .. cy .. "_" .. cz .. ".txt", "w")
	if file then
		file:write(data)
		file:close()
	end
end

local function load_chunk(cx, cy, cz)
	local file = io.open(path .. "/worldgen/biome_chunk_" .. cx .. "_" .. cy .. "_" .. cz .. ".txt", "r")
	if file then
		local data = file:read("*all")
		file:close()

		local chunk = {}
		for i = 1, 4096 do
			local id = string.byte(data, i, i)
			chunk[i] = BIOMES[id]
		end

		return chunk
	end
	return nil
end

local layer_cache = {}

local function make_chunk(index, cy)
	local sy = bit.lshift(cy, 4)
	local chunk = {}

	for i = 0, 15 do
		minetest.log(cy .. " " .. (bit.bor(sy, i) * BIOME_SIZE))
		layer_cache[i + 1] = worldgen.get_layer(bit.bor(sy, i) * BIOME_SIZE).biomes
	end

	math.randomseed(index + SEED)
	for i = 1, 4096 do
		local dy = bit.band(bit.rshift(i, 4), 15)
		local layer_biomes = layer_cache[dy + 1]
		local id = layer_biomes[math.random(#layer_biomes)]
		chunk[i] = BIOMES[id]
	end

	return chunk
end

local DISTORT_X_MAP, DISTORT_Y_MAP, DISTORT_Z_MAP
local biome_pos = {}
local map_x = {}
local map_y = {}
local map_z = {}

worldgen.biome_map.fill_map = function(min_pos, side)
	if not DISTORT_X_MAP then
		local side_inc = side + 1
		local size = {x = side_inc, y = side_inc, z = side_inc}
		params.spread.x = BIOME_SIZE
		params.spread.y = BIOME_SIZE
		params.spread.z = BIOME_SIZE
		params.seed = seed_x
		DISTORT_X_MAP = PerlinNoiseMap(params, size)
		params.seed = seed_y
		DISTORT_Y_MAP = PerlinNoiseMap(params, size)
		params.seed = seed_z
		DISTORT_Z_MAP = PerlinNoiseMap(params, size)
	end

	DISTORT_X_MAP:get_3d_map_flat(min_pos, map_x)
	DISTORT_Y_MAP:get_3d_map_flat(min_pos, map_y)
	DISTORT_Z_MAP:get_3d_map_flat(min_pos, map_z)

	local index = 1
	for z = 0, side do
		for y = 0, side do
			for x = 0, side do
				biome_pos.x = (min_pos.x + x) / BIOME_SIZE + map_x[index]
				biome_pos.y = (min_pos.y + y) / BIOME_SIZE + map_y[index] * 0.1
				biome_pos.z = (min_pos.z + z) / BIOME_SIZE + map_z[index]
				
				local cx = math.floor(biome_pos.x / 16.0)
				local cy = math.floor(biome_pos.y / 16.0)
				local cz = math.floor(biome_pos.z / 16.0)
				
				biome_pos.x = bit.band(math.floor(biome_pos.x), 15)
				biome_pos.y = bit.band(math.floor(biome_pos.y), 15)
				biome_pos.z = bit.band(math.floor(biome_pos.z), 15)

				local chunk_index = (cz * 4096 + cy) * 4096 + cx
				local chunk = DATA[chunk_index]

				if not chunk then
					chunk = load_chunk(cx, cy, cz)
					if not chunk then
						chunk = make_chunk(chunk_index, cy)
						save_chunk(chunk, cx, cy, cz)
					end
					DATA[chunk_index] = chunk
				end

				chunk_index = biome_pos.z * 256 + biome_pos.y * 16 + biome_pos.x + 1
				worldgen.biome_map[index] = chunk[chunk_index]
				index = index + 1
			end
		end
	end
end

worldgen.biome_map.get_biome = function(x, y, z)
	biome_pos.x = x / BIOME_SIZE
	biome_pos.y = y / BIOME_SIZE
	biome_pos.z = z / BIOME_SIZE

	local dx = DISTORT_X_NOISE:get_3d(biome_pos)
	local dy = DISTORT_Y_NOISE:get_3d(biome_pos) * 0.1
	local dz = DISTORT_Z_NOISE:get_3d(biome_pos)
	
	biome_pos.x = biome_pos.x + dx
	biome_pos.y = biome_pos.y + dy
	biome_pos.z = biome_pos.z + dz
	
	local cx = math.floor(biome_pos.x / 16.0)
	local cy = math.floor(biome_pos.y / 16.0)
	local cz = math.floor(biome_pos.z / 16.0)
	
	biome_pos.x = bit.band(math.floor(biome_pos.x), 15)
	biome_pos.y = bit.band(math.floor(biome_pos.y), 15)
	biome_pos.z = bit.band(math.floor(biome_pos.z), 15)

	local index = (cz * 4096 + cy) * 4096 + cx
	local chunk = DATA[index]

	if not chunk then
		chunk = load_chunk(cx, cy, cz)
		if not chunk then
			chunk = make_chunk(index, cy)
			save_chunk(chunk, cx, cy, cz)
		end
		DATA[index] = chunk
	end

	index = biome_pos.z * 256 + biome_pos.y * 16 + biome_pos.x + 1
	return chunk[index]
end

worldgen.biome_map.is_filler = function(node_id)
	for _, biome in ipairs(BIOMES) do
		if node_id == biome.filler then
			return true
		end
	end
	return false
end

minetest.register_on_mods_loaded(function()
	for _, biome in ipairs(BIOMES) do
		if not biome.surface then
			biome.surface = biome.filler
		end
		biome.filler = minetest.get_content_id(biome.filler)
		biome.surface = minetest.get_content_id(biome.surface)
		local color = minetest.colorspec_to_bytes(biome.fog_color)
		local r = string.byte(color, 1)
		local g = string.byte(color, 2)
		local b = string.byte(color, 3)
		biome.fog_color_f = {r = r, g = g, b = b}
	end
end)