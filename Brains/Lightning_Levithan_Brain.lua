
_G["AdExtra.Lightning_Levithan_brain"] = function(body)




    ---@type brain
    local health = body.health
    local Hardness = _G["Hardness"]
    local max_health = 10000
    local hp_threashold = 1 - Hardness
    local FOV = 90
    local target_x = body.values[1] or body.cost_center_x
    local target_y = body.values[2] or body.cost_center_y
    local retreat = body.values[3] or 0
    local cooldown = body.values[4]
    local cooldownRetr = body.values[5]
    local avoidwalldistance = 20

    local bodies = get_visible_bodies(body.id, 200, false)
    local brain = {}
    brain.movement = 0.5
    brain.rotation = 0.2 * rand_normal() * math.sin(0.7 * body.mass)
    brain.ability = false

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
                        local insight = isWithinSector(body,b,FOV*2)
                        is_valid_target = insight
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
    local function CooldownHandler()
        if cooldown > 0 then
            cooldown = math.max(0, cooldown - 1)
        end
        if retreat == 0 then
            if health < (max_health * hp_threashold) and cooldown == 0 then
                retreat = 1
                cooldown = 1000
            end
        end
        if cooldown == 0 then
            retreat = 0
        end

        if cooldownRetr > 0 then
            cooldownRetr = math.max(0, cooldownRetr - 1)
        end
        if retreat == 1 and cooldownRetr == 0 then
            cooldownRetr = 1000
        end
        

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
        if (body.wall_dist > avoidwalldistance - 10 and cooldownRetr > 0) then
            body.rotation = cross(body.dir_x, body.dir_y, body.wall_dx, body.wall_dy)
            body.movement = 1
        else
            avoid_range = avoidwalldistance
            local wall_avoidance = smoothstep(avoid_range, math.max(0.5 * avoid_range, avoid_range - 10.0),
                body.wall_dist)
            brain.movement = lerp(brain.movement, 0.5 * dot(body.wall_dx, body.wall_dy, body.dir_x, body.dir_y),
                wall_avoidance)
        end

    end
    local function Attack()
        local closest_enemy, closest_enemy_id = Retrive("Enemy", true, false) -- Only check for forward-facing enemies

        if closest_enemy and retreat == 0 then
            brain.movement = 1
            brain.ability = true -- Activate ability (e.g., attacking)

            -- Target enemy position
            brain.grab_target_x = closest_enemy.cost_center_x
            brain.grab_target_y = closest_enemy.cost_center_y

            -- Direction to the target
            local dirx = brain.grab_target_x - body.cost_center_x
            local diry = brain.grab_target_y - body.cost_center_y

            -- Check if we have a clear line of sight
            if line_of_sight(body.cost_center_x, body.cost_center_y, brain.grab_target_x, brain.grab_target_y, 1) then
                brain.movement = 1
                brain.rotation = cross(body.dir_x, body.dir_y, dirx, diry)
            end

            -- Avoid walls during the attack
            avoid_walls(body, brain, avoidwalldistance)
        end
    end

    CooldownHandler()

    if retreat == 1 then
        Retreater()
    else
        Attack()
    end

    CooldownHandler()

    -- Wall avoidance is always a fallback
    avoid_walls(body, brain, avoidwalldistance)
    brain.values = {}
    brain.values[1] = body.cost_center_x
    brain.values[2] = body.cost_center_y
    brain.values[3] = retreat
    brain.values[4] = cooldown
    brain.values[5] = cooldownRetr

    return brain
end