local function gradient(y, min_y, max_y, val_b, val_t)
	local delta = (y - min_y) / (max_y - min_y)
	delta = math.clamp(delta, 0.0, 1.0)
	return math.lerp(val_b, val_t, delta)
end

local function smooth_union(a, b, intensity)
    local h = math.clamp(0.5 + 0.5 * (b - a) / intensity, 0.0, 1.0);
    return math.lerp(b, a, h) - intensity * h * (1.0 - h);
end

local function smooth_union_positive(a, b, intensity)
	return -smooth_union(-a, -b, intensity)
end

local function set_rand_seed(seed, x, y)
	math.randomseed(x * 31000 + y + seed)
end

local voronoi_cache = {
	pos = {},
	data = {}
}

for i = 1, 9 do
	voronoi_cache.data[i] = {}
end

local function get_voronoi_2d(seed, x, z)
	local ix = math.floor(x)
	local iz = math.floor(z)

	if voronoi_cache.pos.x ~= ix or voronoi_cache.pos.z ~= iz then
		voronoi_cache.pos.x = ix
		voronoi_cache.pos.z = iz
		local index = 1
		for i = -1, 1 do
			for j = -1, 1 do
				set_rand_seed(seed, ix + i, iz + j)
				local pos = voronoi_cache.data[index]
				pos.x = math.random() * 0.7 + i
				pos.z = math.random() * 0.7 + j
				pos.y = math.random() * 2 - 1
				pos.s = math.random() * 0.5 + 1
				index = index + 1
			end
		end
	end

	local sdx = x - ix
	local sdz = z - iz
	local min = 10000

	local dx, dz, distance

	for i = 1, 9 do
		local pos = voronoi_cache.data[i]

		dx = pos.x - sdx
		dz = pos.z - sdz

		distance = dx * dx + dz * dz

		if distance < min then
			min = distance
		end
	end
	
	return math.sqrt(min)
end

-- Mapgen Bug
--worldgen.register_layer({
--	max_y = 30912,
--	min_y = 30848,
--	density_function = function(layer, pos)
--		local density = gradient(pos.y, layer.min_y, layer.min_y + 10, 1.0, -1.0)
--		density = math.max(density, gradient(pos.y, layer.max_y - 10, layer.max_y, -1.0, 1.0))
--		return density;
--	end
--})

local layer_0_noise_0
local layer_0_noise_1
local layer_0_noise_2
local pos_2d = { x = 0, y = 0 }
local seed_stalactites
local seed_pillars

worldgen.register_layer({
	max_y = 64,
	min_y = 0,
	density_function = function(layer, pos)
		if not layer_0_noise_0 then
			layer_0_noise_0 = minetest.get_perlin({
				offset = 0,
				scale = 1,
				spread = {x = 100, y = 100, z = 100},
				seed = 1,
				octaves = 3,
				persistence = 0.5,
				lacunarity = 2.0,
				flags = "defaults",
			})
			layer_0_noise_1 = minetest.get_perlin({
				offset = 0,
				scale = 1,
				spread = {x = 30, y = 30, z = 30},
				seed = 2,
				octaves = 3,
				persistence = 0.5,
				lacunarity = 2.0,
				flags = "defaults",
			})
			layer_0_noise_2 = minetest.get_perlin({
				offset = 0,
				scale = 1,
				spread = {x = 40, y = 40, z = 40},
				seed = 3,
				octaves = 1,
				persistence = 0.5,
				lacunarity = 2.0,
				flags = "defaults",
			})
			math.randomseed(minetest.get_mapgen_setting("seed"))
			seed_stalactites = math.random(65536)
			seed_pillars = math.random(65536)
		end

		-- Top and bottom gradients
		local middle = (layer.min_y + layer.max_y) * 0.5
		local top_gradient = gradient(pos.y, middle, layer.max_y, -8.0, 1.0)
		local bottom_gradient = gradient(pos.y, layer.min_y, middle, 1.0, -8.0)
		local density = math.max(bottom_gradient, top_gradient)

		-- Global walls
		pos_2d.x = pos.x
		pos_2d.y = pos.z
		local n = layer_0_noise_0:get_2d(pos_2d) * 2.0
		density = smooth_union_positive(density, n, 4.0)

		-- Pillars
		n = (0.05 - get_voronoi_2d(seed_pillars, pos.x * 0.01, pos.z * 0.01)) * 4.0
		density = smooth_union_positive(density, n, 3.0)

		-- Terain variations
		density = density + layer_0_noise_1:get_3d(pos) * 0.6

		-- Stalactites
		n = layer_0_noise_2:get_2d(pos_2d) - 3.0
		n = 0.8 - get_voronoi_2d(seed_stalactites, pos.x * 0.1, pos.z * 0.1) + gradient(pos.y, layer.min_y, layer.max_y, n, 1.0)
		density = smooth_union_positive(density, n, 2.0)

		return density;
	end
})