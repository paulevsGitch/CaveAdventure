local SKY = {
	type = "plain",
	base_color = "#171235",
	clouds = false
}

local INVISIBLE = { visible = false }

minetest.register_on_joinplayer(function(player, last_login)
	player:set_sky(SKY)
	player:set_sun(INVISIBLE)
	player:set_moon(INVISIBLE)
	player:set_stars(INVISIBLE)
end)