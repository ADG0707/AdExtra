_G["AdExtra.Levithan_brain"] = function(body)
    ---@type brain
    
    local brain = {}
    local bodies = get_visible_bodies(body.id, 200, false)

    local health = math.max(body.health or 0, 1)  or 1
    local Hardness = _G["Hardness"] or 0.5
    local max_health = 10000
    local hp_threashold = 1 - Hardness
    local retreat = body.values[3] or 0
    local cooldown = body.values[4] or 1000
    local cooldownRetr = body.values[5] or 1500
    local avoidwalldistance = 20
    brain.movement = 1
    brain.rotation = rand_int(-2,2) * math.sin(body.age)
    avoid_walls(body,brain,50)

    local function CooldownHandler()
        if cooldown > 0 then
            cooldown = math.max(0, cooldown - 1)
        end
        if retreat == 0 then
            if health < (max_health * 0.7) and cooldown == 0 then
                retreat = 1
                cooldown = 400
            end
        end
        if cooldown == 0 then
            retreat = 0
        end

        if cooldownRetr > 0 then
            cooldownRetr = math.max(0, cooldownRetr - 1)
        end
        if retreat == 1 and cooldownRetr == 0 then
            cooldownRetr = 1500
        end

    end
    local function Retrive(type, degrestrict, retr)
        local cbody, cid
        local best_health = -1 -- Track the healthiest target for selection

        for _, b in ipairs(bodies) do
            -- Validate the entity
            if b and b.team and b.health and b.cost_center_x and b.cost_center_y then
                -- Enemy logic
                if type == "Enemy" and b.team ~= body.team then
                    local is_valid_target = true

                    -- Directional restriction
                    if degrestrict then
                        local dot_product = dot(body.dir_x, body.dir_y, b.cost_center_x - body.cost_center_x,
                            b.cost_center_y - body.cost_center_y)
                        is_valid_target = (dot_product > 0)
                    end

                    -- Select the healthiest target
                    if is_valid_target and b.health > 100 and b.health > best_health then
                        cbody = b
                        cid = b.id
                        best_health = b.health
                    end
                end

                -- Ally logic
                if type == "Ally" and b.team == body.team then
                    cbody = b
                    cid = b.id
                    break
                end
            end
        end

        return cbody, cid
    end
    local function Retreater()
        brain.ability = false
        brain.rotation = rand_int(-1, 1) * math.sin(health * 0.01)
        brain.movement = 1
        closest_enemy, closest_enemy_id = Retrive("Enemy", false, true)
        if closest_enemy then

            brain.movement = 1
            if (dot(body.dir_x, body.dir_y, closest_enemy.cost_center_x, closest_enemy.cost_center_y) < 0.9) then
                body.rotation = 0
            else
                local cross_value = cross(body.dir_x, body.dir_y, closest_enemy.cost_center_x,
                    closest_enemy.cost_center_y)
                brain.rotation = cross_value > 0 and 1 or -1
            end
        end
        --if (body.wall_dist > 60 and cooldownRetr > 0) then
        --    body.rotation = cross(body.dir_x, body.dir_y, body.wall_dx, body.wall_dy)
        --    body.movement = 1
        --else
        --    avoid_range = 70.0
        --    local wall_avoidance = smoothstep(avoid_range, math.max(0.5 * avoid_range, avoid_range - 10.0),
        --        body.wall_dist)
        --    brain.movement = lerp(brain.movement, 0.5 * dot(body.wall_dx, body.wall_dy, body.dir_x, body.dir_y),
        --        wall_avoidance)
        --end

    end
    CooldownHandler()
    if(retreat == 1) then
        Retreater()

    end
    brain.values = {}
    brain.values[1] = body.cost_center_x
    brain.values[2] = body.cost_center_y
    brain.values[3] = retreat
    brain.values[4] = cooldown
    brain.values[5] = cooldownRetr

    return brain
end