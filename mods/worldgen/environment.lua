local INVISIBLE = { visible = false }
local PLAYER_DATA = {}
local PLAYER_POS = vector.zero()

local COLOR_INT = {
	{ r = 0, g = 0, b = 0, a = 255 },
	{ r = 0, g = 0, b = 0, a = 255 },
	{ r = 0, g = 0, b = 0, a = 255 },
	{ r = 0, g = 0, b = 0, a = 255 }
}

local function lerp_color(a, b, delta, out)
	out.r = math.lerp(a.r, b.r, delta)
	out.g = math.lerp(a.g, b.g, delta)
	out.b = math.lerp(a.b, b.b, delta)
	return out
end

local function get_sky_data(player)
	local name = player:get_player_name()
	local data = PLAYER_DATA[name]

	if not data then
		data = {}
		PLAYER_DATA[name] = data
		data.sky = {
			type = "plain",
			base_color = "#000000",
			clouds = false
		}
		data.pos = vector.zero()
		data.colors = {
			{ r = 0, g = 0, b = 0 },
			{ r = 0, g = 0, b = 0 },
			{ r = 0, g = 0, b = 0 },
			{ r = 0, g = 0, b = 0 },
			{ r = 0, g = 0, b = 0 },
			{ r = 0, g = 0, b = 0 },
			{ r = 0, g = 0, b = 0 },
			{ r = 0, g = 0, b = 0 }
		}
	end

	local pos = player:get_pos()
	PLAYER_POS.x = bit.lshift(math.floor(pos.x / 16.0), 4)
	PLAYER_POS.y = bit.lshift(math.floor(pos.y /  8.0), 3)
	PLAYER_POS.z = bit.lshift(math.floor(pos.z / 16.0), 4)

	if not data.colors or data.pos.x ~= PLAYER_POS.x or data.pos.y ~= PLAYER_POS.y or data.pos.z ~= PLAYER_POS.z then
		data.pos.x = PLAYER_POS.x
		data.pos.y = PLAYER_POS.y
		data.pos.z = PLAYER_POS.z

		data.colors[1] = worldgen.biome_map.get_biome(PLAYER_POS.x, PLAYER_POS.y, PLAYER_POS.z).fog_color_f
		data.colors[2] = worldgen.biome_map.get_biome(PLAYER_POS.x + 16, PLAYER_POS.y, PLAYER_POS.z).fog_color_f
		data.colors[3] = worldgen.biome_map.get_biome(PLAYER_POS.x, PLAYER_POS.y + 8, PLAYER_POS.z).fog_color_f
		data.colors[4] = worldgen.biome_map.get_biome(PLAYER_POS.x + 16, PLAYER_POS.y + 8, PLAYER_POS.z).fog_color_f
		data.colors[5] = worldgen.biome_map.get_biome(PLAYER_POS.x, PLAYER_POS.y, PLAYER_POS.z + 16).fog_color_f
		data.colors[6] = worldgen.biome_map.get_biome(PLAYER_POS.x + 16, PLAYER_POS.y, PLAYER_POS.z + 16).fog_color_f
		data.colors[7] = worldgen.biome_map.get_biome(PLAYER_POS.x, PLAYER_POS.y + 8, PLAYER_POS.z + 16).fog_color_f
		data.colors[8] = worldgen.biome_map.get_biome(PLAYER_POS.x + 16, PLAYER_POS.y + 8, PLAYER_POS.z + 16).fog_color_f
	end

	local dx = (pos.x - PLAYER_POS.x) / 16.0
	local dy = (pos.y - PLAYER_POS.y) /  8.0
	local dz = (pos.z - PLAYER_POS.z) / 16.0

	local a = lerp_color(data.colors[1], data.colors[2], dx, COLOR_INT[1])
	local b = lerp_color(data.colors[3], data.colors[4], dx, COLOR_INT[2])
	local c = lerp_color(data.colors[5], data.colors[6], dx, COLOR_INT[3])
	local d = lerp_color(data.colors[7], data.colors[8], dx, COLOR_INT[4])

	local a = lerp_color(a, b, dy, COLOR_INT[1])
	local b = lerp_color(c, d, dy, COLOR_INT[2])

	data.sky.base_color = lerp_color(a, b, dz, COLOR_INT[1])

	return data
end

minetest.register_on_joinplayer(function(player, last_login)
	local data = get_sky_data(player)
	player:set_sky(data.sky)
	player:set_sun(INVISIBLE)
	player:set_moon(INVISIBLE)
	player:set_stars(INVISIBLE)
end)

local timer = 0.0

minetest.register_globalstep(function(dtime)
	timer = timer + dtime
	if timer >= 0.25 then
		timer = timer - 0.25
		for _, player in ipairs(minetest.get_connected_players()) do
			local data = get_sky_data(player)
			player:set_sky(data.sky)
		end
	end
end)