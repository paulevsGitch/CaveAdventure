-- Registering building set:
-- radial_menu.register_building_set({"node_1", "node_2"})

radial_menu = {}

local function make_formscpec(selected_node, node_list)
	local formspec_table = {
		"formspec_version[7]",
		"size[10,8]",
		"bgcolor[;neither;]",
		"no_prepend[]",
		"image[1,0;8,8;circle.png;false]"
	}
	
	table.insert(formspec_table, "item_image[4,3;2,2;" .. selected_node .. "]")
	
	local count = #node_list
	
	for i = 1, count do
		local angle = (i - 1) * 2.0 * math.pi / count
		local px = 4.5 + math.sin(angle) * 3.0
		local py = 3.5 - math.cos(angle) * 3.0
		local desc = minetest.registered_items[node_list[i]].description
		table.insert(formspec_table, "image_button[" .. (px - 1.0) .. "," .. (py + 0.75) .. ";3,1;blank.png;button_" .. i .. "_text;" .. desc .. ";false;false]")
		table.insert(formspec_table, "image_button[" .. px .. "," .. py .. ";1,1;blank.png;button_" .. i .. ";;false;false]")
		table.insert(formspec_table, "item_image[" .. px .. "," .. py .. ";1,1;" .. node_list[i] .. "]")
	end
	
	return table.concat(formspec_table)
end

local SELECTED = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	local node_list = SELECTED[player:get_player_name()]
	local button_index = 0

	for k, _ in pairs(fields) do
		if string.sub(k, 1, 6) == "button" then
			local name = string.gsub(string.sub(k, 8, -1), "_text", "")
			button_index = tonumber(name, 10)
		end
	end

	if button_index > 0 then
		local inventory = player:get_inventory()
		local index = player:get_wield_index()
		local stack = inventory:get_stack("main", index)
		stack:set_name(node_list[button_index])
		inventory:set_stack("main", index, stack)
	end
end)

radial_menu.register_building_set = function (node_list)
	for _, node_name in ipairs(node_list) do
		local on_place = minetest.registered_nodes[node_name].on_place
		local formspec = make_formscpec(node_name, node_list)

		minetest.override_item(node_name, {
			on_place = function(itemstack, placer, pointed_thing)
				local control = placer:get_player_control()
				if control.sneak then
					SELECTED[placer:get_player_name()] = node_list
					minetest.show_formspec(placer:get_player_name(), "radial_menu:test", formspec)
					return itemstack
				end
				return on_place(itemstack, placer, pointed_thing)
			end
		})
	end
end