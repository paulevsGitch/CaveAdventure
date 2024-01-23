node_shapes = {}

local S = minetest.get_translator()

local SLAB_BOX = {
	type = "fixed",
	fixed = {-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
}

local STAIRS_BOX = {
	type = "fixed",
	fixed = {
		--{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
		--{-0.5, 0.0, -0.5, 0.0, 0.5, 0.5}
		{-0.5, -0.5, -0.5, 0.5, 0.0, 0.5},
		{-0.5, 0.0, 0.0, 0.5, 0.5, 0.5}
	}
}

local PILLAR_BOX = {
	type = "connected",
	fixed = {-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125},
	disconnected_top = {
		{-0.4375, 0.3125, -0.4375, 0.4375, 0.5, 0.4375},
		{-0.375, 0.125, -0.375, 0.375, 0.3125, 0.375}
	},
	disconnected_bottom = {
		{-0.4375, -0.3125, -0.4375, 0.4375, -0.5, 0.4375},
		{-0.375, -0.125, -0.375, 0.375, -0.3125, 0.375}
	}
}

local STAIRS_ANGLES = { 5, 7, 11, 9 }

-- 0 = y+,   1 = z+,   2 = z-,   3 = x+,   4 = x-,   5 = y-
local function simple_facedir(dir)
	if dir.x == 1 then
		return 4
	elseif dir.x == -1 then
		return 3
	elseif dir.y == 1 then
		return 5
	elseif dir.y == -1 then
		return 0
	elseif dir.z == 1 then
		return 2
	else
		return 1
	end
end

local function place_slab(itemstack, placer, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
	local index = minetest.dir_to_wallmounted(dir)
	if minetest.get_node_group(node.name, "slab") > 0 and not placer:get_player_control().sneak then
		if index == node.param2 then
			node.name = node.name .. "_double"
			minetest.set_node(pointed_thing.under, node)
			if not minetest.is_creative_enabled(placer:get_player_name()) then
				itemstack:set_count(itemstack:get_count() - 1)
			end
			return itemstack
		elseif bit.rshift(index, 1) ~= bit.rshift(node.param2, 1) then
			index = node.param2
		end
	end
	return minetest.item_place(itemstack, placer, pointed_thing, index)
end

local function place_stairs(itemstack, placer, pointed_thing)
	local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
	local vec = placer:get_look_dir()
	
	local index = 0
	
	if dir.y ~= 0 then
		local ax = math.abs(vec.x)
		local az = math.abs(vec.z)
		local mx = math.max(ax, az)
		local rotation = 0
		
		if dir.y < 0 then
			if mx == ax then
				if vec.x > 0 then
					rotation = 1
				else
					rotation = 3
				end
			else
				if vec.z > 0 then
					rotation = 0
				else
					rotation = 2
				end
			end
		else
			if mx == ax then
				if vec.x > 0 then
					rotation = 3
				else
					rotation = 1
				end
			else
				if vec.z > 0 then
					rotation = 0
				else
					rotation = 2
				end
			end
		end
		
		index = bit.bor(bit.lshift(simple_facedir(dir), 2), rotation)
	else
		local rotation = math.atan2(vec.x, vec.z)
		rotation = math.floor((rotation + math.pi) * 2.0 / math.pi)
		rotation = bit.band(rotation + 1, 3) + 1
		index = STAIRS_ANGLES[rotation]
	end
	
	--local index = bit.bor(bit.lshift(simple_facedir(dir), 2), rotation)
	return minetest.item_place(itemstack, placer, pointed_thing, index)
end

local function place_pillar(itemstack, placer, pointed_thing)
	local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
	local index = minetest.dir_to_wallmounted(dir)
	index = bit.bor(bit.band(index, 6), 1)
	return minetest.item_place(itemstack, placer, pointed_thing, index)
end

node_shapes.register_slab = function (node_name, node_description)
	local def = table.copy(minetest.registered_nodes[node_name])
	if not def.groups then def.groups = {} end
	def.groups.slab = 1
	
	def.description = S(node_description .. " Slab")
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "wallmounted"
	def.node_box = SLAB_BOX
	def.on_place = place_slab

	minetest.register_node(node_name .. "_slab", def)
	
	def = table.copy(def)
	def.groups.not_in_creative_inventory = 1
	def.groups.double_slab = 1
	def.groups.slab = nil
	def.drop = node_name .. "_slab 2"
	
	minetest.register_node(node_name .. "_double_slab", def)
end

node_shapes.register_stairs = function (node_name, node_description)
	local def = table.copy(minetest.registered_nodes[node_name])
	if not def.groups then def.groups = {} end
	def.groups.stairs = 1

	def.description = S(node_description .. " Pillar")
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.node_box = STAIRS_BOX
	def.on_place = place_stairs

	minetest.register_node(node_name .. "_stairs", def)
end

node_shapes.register_pillar = function (node_name, node_description)
	local def = table.copy(minetest.registered_nodes[node_name])
	if not def.groups then def.groups = {} end
	def.groups.pillar = 1

	def.description = S(node_description .. " Pillar")
	def.paramtype2 = "wallmounted"
	def.on_place = place_pillar

	minetest.register_node(node_name .. "_pillar", def)
end

node_shapes.register_thin_pillar = function (node_name, node_description)
	local def = table.copy(minetest.registered_nodes[node_name])
	if not def.groups then def.groups = {} end
	def.groups.thin_pillar = 1

	def.description = S(node_description .. " Thin Pillar")
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.connects_to = {"group:thin_pillar"}
	def.node_box = PILLAR_BOX

	minetest.register_node(node_name .. "_thin_pillar", def)
end

node_shapes.register_variants = function (node_name, node_description)
	node_shapes.register_slab(node_name, node_description)
	node_shapes.register_stairs(node_name, node_description)
	node_shapes.register_pillar(node_name, node_description)
	node_shapes.register_thin_pillar(node_name, node_description)
end