-- Registering building set:
-- radial_menu.register_building_set({"node_1", "node_2"})

radial_menu = {}

local RADIAL_MENU_ID = "radial_menu:block_variant"

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
		local desc = minetest.formspec_escape(minetest.registered_items[node_list[i]].description)
		table.insert(formspec_table, "image_button[" .. px .. "," .. py .. ";1,1;blank.png;button_" .. i .. ";;false;false]")
		table.insert(formspec_table, "item_image[" .. px .. "," .. py .. ";1,1;" .. node_list[i] .. "]")
		table.insert(formspec_table, "tooltip[" .. px .. "," .. py .. ";1,1;" .. desc .. ";#00000033;#FFFFFFFF]")
	end
	
	return table.concat(formspec_table)
end

local SELECTED = {}

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname ~= RADIAL_MENU_ID then return end
	
	local name = player:get_player_name()
	local node_list = SELECTED[name]
	local button_index = 0

	for k, _ in pairs(fields) do
		if string.sub(k, 1, 6) == "button" then
			local name = string.sub(k, 8, -1)
			button_index = tonumber(name, 10)
		end
	end

	if button_index > 0 then
		local inventory = player:get_inventory()
		local index = player:get_wield_index()
		local stack = inventory:get_stack("main", index)
		stack:set_name(node_list[button_index])
		inventory:set_stack("main", index, stack)
		minetest.close_formspec(name, formname)
	end
end)

radial_menu.register_shapes_set = function (node_list)
	for _, node_name in ipairs(node_list) do
		local formspec = make_formscpec(node_name, node_list)
		minetest.override_item(node_name, {
			on_use = function(stack, player, pointed_thing)
				SELECTED[player:get_player_name()] = node_list
				minetest.show_formspec(player:get_player_name(), RADIAL_MENU_ID, formspec)
			end
		})
	end
end