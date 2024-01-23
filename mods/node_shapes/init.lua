node_shapes = {}

local S = minetest.get_translator("node_shapes")

local DESC_SLAB = S("Slab")
local DESC_STAIRS = S("Stairs")
local DESC_PILLAR = S("Pillar")
local DESC_THIN_PILLAR = S("Thin Pillar")

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

local PILLAR_BOX_MIDDLE = {
	type = "fixed",
	fixed = {-0.3125, -0.5, -0.3125, 0.3125, 0.5, 0.3125}
}

local PILLAR_BOX_TOP = {
	type = "fixed",
	fixed = {
		{-0.3125, -0.5, -0.3125, 0.3125, 0.45, 0.3125},
		{-0.4375, 0.3125, -0.4375, 0.4375, 0.5, 0.4375},
		{-0.375, 0.125, -0.375, 0.375, 0.3125, 0.375}
	}
}

local PILLAR_BOX_BOTTOM = {
	type = "fixed",
	fixed = {
		{-0.3125, -0.45, -0.3125, 0.3125, 0.5, 0.3125},
		{-0.4375, -0.3125, -0.4375, 0.4375, -0.5, 0.4375},
		{-0.375, -0.125, -0.375, 0.375, -0.3125, 0.375}
	}
}

local PILLAR_BOX_SMALL = {
	type = "fixed",
	fixed = {
		{-0.3125, -0.45, -0.3125, 0.3125, 0.45, 0.3125},
		{-0.4375, 0.3125, -0.4375, 0.4375, 0.5, 0.4375},
		{-0.375, 0.125, -0.375, 0.375, 0.3125, 0.375},
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

local function world_align_textures(tiles)
	for index, texture in ipairs(tiles) do
		if type("texture") == "string" then
			tiles[index] = {
				name = texture,
				backface_culling = true,
				align_style="world"
			}
		end
	end
end

local function apply_overrides(def, overrides)
	if not overrides then return end
	for k, v in pairs(overrides) do
		def[k] = v
	end
end

local function place_slab(itemstack, placer, pointed_thing)
	local node = minetest.get_node(pointed_thing.under)
	local dir = vector.subtract(pointed_thing.under, pointed_thing.above)
	local index = minetest.dir_to_wallmounted(dir)
	if minetest.get_node_group(node.name, "slab") > 0 and not placer:get_player_control().sneak then
		if index == node.param2 then
			node.name = node.name .. "_double_slab"
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

local mutable_pos = {}

local function is_pillar(x, y, z, param2)
	mutable_pos.x = x
	mutable_pos.y = y
	mutable_pos.z = z
	local node = minetest.get_node(mutable_pos)
	return node.param2 == param2 and minetest.get_item_group(node.name, "thin_pillar") == 1
end

local pillar_pos = {}

local function update_thin_pillar(x, y, z)
	pillar_pos.x = x
	pillar_pos.y = y
	pillar_pos.z = z
	
	local node = minetest.get_node(pillar_pos)
	
	if minetest.get_item_group(node.name, "thin_pillar") ~= 1 then return end
	
	local bottom = false
	local top = false
	
	if node.param2 == 12 then
		bottom = is_pillar(x - 1, y, z, node.param2)
		top = is_pillar(x + 1, y, z, node.param2)
	elseif node.param2 == 4 then
		bottom = is_pillar(x, y, z - 1, node.param2)
		top = is_pillar(x, y, z + 1, node.param2)
	else
		bottom = is_pillar(x, y - 1, z, node.param2)
		top = is_pillar(x, y + 1, z, node.param2)
	end
	
	--local name = node.name
	local name = string.sub(node.name, 1, string.find(node.name, "_thin_pillar", 1, true) + 11)
	if bottom and top then name = name .. "_middle"
	elseif bottom and not top then name = name .. "_top"
	elseif not bottom and top then name = name .. "_bottom" end
	
	if name ~= node.name then
		node.name = name
		minetest.set_node(pillar_pos, node)
	end
end

local function place_thin_pillar(itemstack, placer, pointed_thing)
	local under = pointed_thing.under
	local above = pointed_thing.above
	
	local dx = above.x - under.x
	local dz = above.z - under.z
	
	local node_name = itemstack:get_name()
	local bottom = false
	local top = false
	local param2 = 0
	
	if dx ~= 0 then
		param2 = 12
		bottom = is_pillar(under.x - 1, under.y, under.z, param2)
		top = is_pillar(under.x + 1, under.y, under.z, param2)
	elseif dz ~= 0 then
		param2 = 4
		bottom = is_pillar(under.x, under.y, under.z - 1, param2)
		top = is_pillar(under.x, under.y, under.z + 1, param2)
	else
		bottom = is_pillar(under.x, under.y - 1, under.z, param2)
		top = is_pillar(under.x, under.y + 1, under.z, param2)
	end
	
	local place_name = node_name.sub(node_name, 1, string.find(node_name, "_thin_pillar", 1, true) + 11)
	if bottom and top then place_name = place_name .. "_middle"
	elseif bottom and not top then place_name = place_name .. "_top"
	elseif not bottom and top then place_name = place_name .. "_bottom" end

	itemstack:set_name(place_name)
	local result = minetest.item_place_node(itemstack, placer, pointed_thing, param2)
	itemstack:set_name(node_name)
	
	update_thin_pillar(above.x, above.y, above.z)
	
	if dx ~= 0 then
		update_thin_pillar(above.x - 1, above.y, above.z)
		update_thin_pillar(above.x + 1, above.y, above.z)
	elseif dz ~= 0 then
		update_thin_pillar(above.x, above.y, above.z - 1)
		update_thin_pillar(above.x, above.y, above.z + 1)
	else
		update_thin_pillar(above.x, above.y - 1, above.z)
		update_thin_pillar(above.x, above.y + 1, above.z)
	end
	
	return result
end

local function after_break_thin_pillar(pos, oldnode, oldmetadata, digger)
	minetest.chat_send_all(oldnode.param2)
	if oldnode.param2 == 12 then
		update_thin_pillar(pos.x - 1, pos.y, pos.z)
		update_thin_pillar(pos.x + 1, pos.y, pos.z)
	elseif oldnode.param2 == 4 then
		update_thin_pillar(pos.x, pos.y, pos.z - 1)
		update_thin_pillar(pos.x, pos.y, pos.z + 1)
	else
		update_thin_pillar(pos.x, pos.y - 1, pos.z)
		update_thin_pillar(pos.x, pos.y + 1, pos.z)
	end
end

node_shapes.register_slab = function (node_name, overrides)
	local def = table.copy(minetest.registered_nodes[node_name])
	world_align_textures(def.tiles)
	apply_overrides(def, overrides)
	if not def.groups then def.groups = {} end
	def.groups.slab = 1
	
	def.description = def.description .. " [" .. DESC_SLAB .. "]"
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

node_shapes.register_stairs = function (node_name, overrides)
	local def = table.copy(minetest.registered_nodes[node_name])
	apply_overrides(def, overrides)
	world_align_textures(def.tiles)
	if not def.groups then def.groups = {} end
	def.groups.stairs = 1

	def.description = def.description .. " [" .. DESC_STAIRS .. "]"
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.node_box = STAIRS_BOX
	def.on_place = place_stairs

	minetest.register_node(node_name .. "_stairs", def)
end

node_shapes.register_pillar = function (node_name, overrides)
	local def = table.copy(minetest.registered_nodes[node_name])
	apply_overrides(def, overrides)
	if not def.groups then def.groups = {} end
	def.groups.pillar = 1

	def.description = def.description .. " [" .. DESC_PILLAR .. "]"
	def.paramtype2 = "wallmounted"
	def.on_place = place_pillar

	minetest.register_node(node_name .. "_pillar", def)
end

node_shapes.register_thin_pillar = function(node_name, overrides)
	local def = table.copy(minetest.registered_nodes[node_name])
	local tex_pref = string.gsub(node_name, ":", "_") .. "_pillar"

	apply_overrides(def, overrides)
	if not def.groups then def.groups = {} end
	def.groups.thin_pillar = 1
	
	def.description = def.description .. " [" .. DESC_THIN_PILLAR .. "]"
	def.paramtype2 = "facedir"
	def.paramtype = "light"
	def.drawtype = "mesh"
	
	def.on_place = place_thin_pillar
	def.after_dig_node = after_break_thin_pillar
	
	local pillar = node_name .. "_thin_pillar"
	def.drop = pillar
	
	def.mesh = "node_shapes_thin_pillar_small.obj"
	def.tiles = {tex_pref .. "_ends.png", tex_pref .. "_top.png"}
	def.selection_box = PILLAR_BOX_SMALL
	def.collision_box = PILLAR_BOX_SMALL
	minetest.register_node(pillar, def)
	
	def = table.copy(def)
	def.groups.not_in_creative_inventory = 1
	def.selection_box = PILLAR_BOX_BOTTOM
	def.collision_box = PILLAR_BOX_BOTTOM
	def.mesh = "node_shapes_thin_pillar_bottom.obj"
	def.tiles = {tex_pref .. "_ends.png", tex_pref .. "_top.png", tex_pref .. "_middle.png"}
	minetest.register_node(pillar .. "_bottom", def)
	
	def = table.copy(def)
	def.mesh = "node_shapes_thin_pillar_top.obj"
	def.selection_box = PILLAR_BOX_TOP
	def.collision_box = PILLAR_BOX_TOP
	minetest.register_node(pillar .. "_top", def)
	
	def = table.copy(def)
	def.selection_box = PILLAR_BOX_MIDDLE
	def.collision_box = PILLAR_BOX_MIDDLE
	def.mesh = "node_shapes_thin_pillar_middle.obj"
	def.tiles = {tex_pref .. "_middle.png"}
	minetest.register_node(pillar .. "_middle", def)
end