---@type mod_calllbacks
-- api_version should be the current version of the modloader, if your mod requires a more recent version than is installed we will error
-- version is the version number of your mod



-- AdExtra:

-- * Parameters in mod list:
--      ** Hardness : 0-1 (float) Recommended 0.6
--      ** spawn_rates : 0-2 - spwaning rate
-- * Credits : ADG232 (discord)


--:::More Coming soon:::

-- Brains:

        dofile("data/scripts/lua_mods/mods/AdExtra/Brains/Adag_brain.lua")
        dofile("data/scripts/lua_mods/mods/AdExtra/Brains/AdagChild_brain.lua")
        dofile("data/scripts/lua_mods/mods/AdExtra/Brains/Levithan_brain.lua")
        dofile("data/scripts/lua_mods/mods/AdExtra/Brains/Blackhole_brain.lua")
        dofile("data/scripts/lua_mods/mods/AdExtra/Brains/Lightning_Levithan_Brain.lua")
        dofile("data/scripts/lua_mods/mods/AdExtra/Brains/flame_Brain.lua")



local M = {
    api_version = 0,
    version = "1.1.0"
}







---@type spawn_function
_G["AdExtra.explosion_resist"] = function(body_id, x, y)
    give_mutation(body_id, MUT_EXPLOSIVE_RESISTANCE)
    return {nil, nil, x, y} -- this determines spawn extra info
end
_G["AdExtra.cancer"] = function(body_id, x, y)
    give_mutation(body_id, MUT_CANCER )
    return {nil, nil, x, y} -- this determines spawn extra info
end
_G["AdExtra.speed"] = function(body_id, x, y)
    give_mutation(body_id, MUT_DRIFTING )
    return {nil, nil, x, y} -- this determines spawn extra info
end
_G["AdExtra.Lightning_Levithan"] = function(body_id, x, y)
    give_mutation(body_id, MUT_CHAIN_LIGHTNING )
    give_mutation(body_id, MUT_DRIFTING )
    give_mutation(body_id, MUT_EXPLOSIVE_RESISTANCE )

    return {nil, nil, x, y} -- this determines spawn extra info
end

-- pre hook is for changing how functions that everyone uses behaves
function M.pre(api, config)
    -- shadow the add_creature_spawn_chance function so we can modify it
    local old_add_creature_spawn_chance = add_creature_spawn_chance
    function add_creature_spawn_chance(...)
        local args = {...} -- collect the arguments into a table for easy modification
        args[4] = args[4] -- this arg is the xp drop amount, so make everything drop 20x xp
        return old_add_creature_spawn_chance(unpack(args)) -- call the original with the modified args
    end
	
end

-- post hook is for defining creatures
function M.post(api, config)
    local spawn_rate = config.spawn_rates or 0.05
    _G["Hardness"] = config.Hardness

    -- we shadow the creature_list function to call our additional code after it
    local old_creature_list = creature_list
    creature_list = function(...)
        -- call the original
        local r = {old_creature_list(...)}

        -- register our creatures
        register_creature(api.acquire_id("AdExtra.Adag"), "data/scripts/lua_mods/mods/AdExtra/creatures/Adag.bod",
            "AdExtra.Adag_brain","AdExtra.explosion_resist")
		register_creature(api.acquire_id("AdExtra.Child"), "data/scripts/lua_mods/mods/AdExtra/creatures/AdagChild.bod",
            "AdExtra.AdagChild_brain")
        register_creature(api.acquire_id("AdExtra.Levithan"), "data/scripts/lua_mods/mods/AdExtra/creatures/cancer_Levithan.bod",
            "AdExtra.Levithan_brain","AdExtra.cancer")
        register_creature(api.acquire_id("AdExtra.Black_Hole"), "data/scripts/lua_mods/mods/AdExtra/creatures/blockhole.bod",
            "AdExtra.Black_Hole_Brain","AdExtra.explosion_resist")
        register_creature(api.acquire_id("AdExtra.Lightning_Levithan"), "data/scripts/lua_mods/mods/AdExtra/creatures/Lightning_Levithan.bod",
            "AdExtra.Lightning_Levithan_brain","AdExtra.Lightning_Levithan")
        register_creature(api.acquire_id("AdExtra.Flamer"), "data/scripts/lua_mods/mods/AdExtra/creatures/flamer.bod",
            "AdExtra.flame_brain","AdExtra.explosion_resist")
        -- return the result of the original, not strictly neccesary here but useful in some situations
        return unpack(r)
    end

    -- shadow init_biomes function to call our stuff afterwards
    local old_init_biomes = init_biomes
    init_biomes = function(...)
        local r = {old_init_biomes(...)}
        -- add our creatures to the starting biome, if spawn_rates are too high you will start to see issues where only some creatures can spawn
        -- to fix this make sure the sum isn't too high, i will perhaps add a prehook for compat with this in future
        add_creature_spawn_chance("FIRE", api.acquire_id("AdExtra.Adag"), spawn_rate, 40)
		add_creature_spawn_chance("FIRE", api.acquire_id("AdExtra.Child"), spawn_rate * 2, 10)
        add_creature_spawn_chance("STRT", api.acquire_id("AdExtra.Levithan"), spawn_rate / 10, 14)
        add_creature_spawn_chance("FIRE", api.acquire_id("AdExtra.Black_Hole"), spawn_rate / 20, 100)
        add_creature_spawn_chance("ICEE", api.acquire_id("AdExtra.Lightning_Levithan"), spawn_rate / 7, 300)
        add_creature_spawn_chance("FIRE", api.acquire_id("AdExtra.Flamer"), spawn_rate * 0.6, 40)



        return unpack(r)
    end
end

return M
