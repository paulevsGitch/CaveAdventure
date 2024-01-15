worldgen = {}

local path = minetest.get_modpath("worldgen")

dofile(path .. "/layer_api.lua")
dofile(path .. "/layers.lua")
dofile(path .. "/generator.lua")
dofile(path .. "/environment.lua")
dofile(path .. "/spawnpoint.lua")