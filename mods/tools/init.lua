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

cracks_textures[1] = {"cracks1.png", "cracks1.png", "cracks1.png", "cracks1.png", "cracks1.png", "cracks1.png"}
cracks_textures[2] = {"cracks2.png", "cracks2.png", "cracks2.png", "cracks2.png", "cracks2.png", "cracks2.png"}
cracks_textures[3] = {"cracks3.png", "cracks3.png", "cracks3.png", "cracks3.png", "cracks3.png", "cracks3.png"}
cracks_textures[4] = {"cracks4.png", "cracks4.png", "cracks4.png", "cracks4.png", "cracks4.png", "cracks4.png"}
cracks_textures[5] = {"cracks5.png", "cracks5.png", "cracks5.png", "cracks5.png", "cracks5.png", "cracks5.png"}
cracks_textures[6] = {"cracks6.png", "cracks6.png", "cracks6.png", "cracks6.png", "cracks6.png", "cracks6.png"}
cracks_textures[7] = {"cracks7.png", "cracks7.png", "cracks7.png", "cracks7.png", "cracks7.png", "cracks7.png"}
cracks_textures[8] = {"cracks8.png", "cracks8.png", "cracks8.png", "cracks8.png", "cracks8.png", "cracks8.png"}

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

minetest.register_on_punchnode(function(pos, oldnode, digger)
    if not digger then return end

    local wielded = digger:get_wielded_item()
    local time = dig_times[digger:get_player_name()]
    
    if time and os.clock() - time < 0.1 then return end

    dig_times[digger:get_player_name()] = os.clock()

    if wielded and wielded:get_name() == "tools:pickaxe" then
        local node = minetest.get_node(pos)

        if node.name == "air" then return end
        if node.name == "unknown" then return end
        if node.name == "ignore" then return end

        local node_hp = minetest.registered_nodes[node.name].node_hp or 3

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