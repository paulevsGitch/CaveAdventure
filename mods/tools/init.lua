local path = minetest.get_modpath("tools")

tools = {}

minetest.register_craftitem("tools:pickaxe", 
{
    description = "Pickaxe",
    inventory_image = "emerald_pickaxe.png",
})

--not saved
local dig_state = {}
local dig_times = {}

local cracks_textures = {}

for i = 1,8 do
    local name = "tools_dig_cracks" .. i .. ".png"
    cracks_textures[i] = {}
    for j = 1,6 do cracks_textures[i][j] = name end
end

minetest.register_entity(
    "tools:cracks",
    {
        initial_properties =
        {
            physical = false,
            collide_with_objects = false,
            visual = "cube",
            visual_size = vector.new(1.001, 1.001, 1.001),
            textures = cracks_textures[1],
            pointable = false,
            static_save = false, --prevent saving since break state isnt saved either
        }
    }
)

minetest.register_entity(
    "tools:tool", 
    {
        initial_properties =
        {
            physical = false,
            collide_with_objects = false,
            visual = "wielditem",
            visual_size = vector.new(0.5, 0.5, 0.5),
        
            pointable = false,
            static_save = false
        }
    }
)

local player_wield_items = {}

minetest.register_on_joinplayer(function(player_ref, last_login)

    player_ref:hud_set_flags({wielditem = false})

    minetest.after(0.2, function ()
        local player_pos = player_ref:get_pos()
        local wield_entity = minetest.add_entity(player_pos, "tools:tool")

        wield_entity:set_attach(player_ref, "", {x = 5, y = 10, z = 5}, {x = 0, y = -90, z = 0}, true)
        wield_entity:set_properties({wield_item = "tools:pickaxe"})

        player_wield_items[player_ref:get_player_name()] = {player = player_ref, wield = wield_entity}
    
    end)
end)

minetest.register_on_leaveplayer(function(player_ref, timed_out)
    local wield_entity = player_wield_items[player_ref:get_player_name()].wield
    wield_entity:set_detach()
    wield_entity:remove()
    player_wield_items[player_ref:get_player_name()] = nil
end)

minetest.register_globalstep(function(dtime)
    for _, player in pairs(player_wield_items) do
        local wielded = player.player:get_wielded_item()
        local wield_entity = player.wield

        if wielded:get_name() ~= wield_entity:get_properties().wield_item then
            wield_entity:set_properties({wield_item = wielded:get_name()})
        end
    end
end)

minetest.register_on_punchnode(function(pos, oldnode, digger)
    if not digger then return end

    local wielded = digger:get_wielded_item()
    local time = dig_times[digger:get_player_name()]
    
    if time and os.clock() - time < 0.1 then return end

    dig_times[digger:get_player_name()] = os.clock()

    if wielded and wielded:get_name() == "tools:pickaxe" then
        local node = minetest.get_node(pos)
        local nodedef = minetest.registered_nodes[node.name]

        if not nodedef then return end

        local node_hp = node.node_hp or 3

        local dig_key = tools.vector_to_string(pos)
        local state = dig_state[dig_key]

        if not state then
            state = {hits = 1, entity = minetest.add_entity(pos, "tools:cracks")}
        end

        if state.hits > node_hp - 1 then
            minetest.dig_node(pos)
            state.entity:remove()
            state = nil
        else
            state.hits = state.hits + 1

            local index = math.floor(((state.hits - 1) / node_hp) * 8)

            state.entity:set_properties({textures = cracks_textures[index]})
        end

        dig_state[dig_key] = state
    end
end)

tools.vector_to_string = function(vec)
    return vec.x .. "," .. vec.y .. "," .. vec.z
end

tools.string_to_vector = function(str)
    local vec = {}
    local i = 1
    for num in string.gmatch(str, "([^,]+)") do
        vec[i] = tonumber(num)
        i = i + 1
    end
    return vector.new(vec[1], vec[2], vec[3])
end