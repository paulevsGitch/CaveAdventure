local storage = minetest.get_mod_storage()
local spawn_pos = minetest.string_to_pos(storage:get("world_spawn_pos") or "")

local function update_spawn()
	spawn_pos = vector.new(0, 32, 0)
	local layer = worldgen.get_layer(32)
	for _ = 1, 1000 do
		spawn_pos.x = math.random(-256, 256)
		spawn_pos.z = math.random(-256, 256)
		if layer:density_function(spawn_pos) < 0 then
			while layer:density_function(spawn_pos) < 0 do
				spawn_pos.y = spawn_pos.y - 1
			end
			spawn_pos.y = spawn_pos.y + 1
			goto break_search
		end
	end
	::break_search::
	storage:set_string("world_spawn_pos", minetest.pos_to_string(spawn_pos))
end

minetest.register_on_respawnplayer(function(player)
	update_spawn()
	player:set_pos(spawn_pos)
	return true
end)

minetest.register_on_joinplayer(function(player, last_login)
	if not last_login then
		update_spawn()
		player:set_pos(spawn_pos)
	end
end)