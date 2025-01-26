_G["AdExtra.Assasin_brain"] = function(body)
    ---@type brain
    local brain = {}
    body.team = 3
    local health = body.health
    
    local max_health = 600

    local target_x = body.values[1] or body.cost_center_x
    local target_y = body.values[2] or body.cost_center_y
    local retreat = body.values[3]
    local cooldown = body.values[4]
    local cooldownRetr = body.values[5]

    local bodies = get_visible_bodies(body.id, 500, false)
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


    local function Attack()
        local closest_enemy, closest_enemy_id = Retrive("Enemy", true, false) -- Only check for forward-facing enemies
        

        if closest_enemy then
        local evel = math.sqrt(closest_enemy.vel_x^2 + closest_enemy.vel_y^2)
        local bvel = math.sqrt(body.vel_x^2 + body.vel_y^2)

            brain.movement = 1
            brain.grab_target_x = closest_enemy.cost_center_x
            brain.grab_target_y = closest_enemy.cost_center_y
            local dirx = brain.grab_target_x - body.cost_center_x
            local diry = brain.grab_target_y - body.cost_center_y
            local distance = math.sqrt((body.cost_center_x - brain.grab_target_x)^2 + (body.cost_center_y - brain.grab_target_y)^2)
            
            -- Target enemy position
           
            brain.grab_dir = -1
            -- Direction to the target
            
            if (evel > bvel and not (distance < 60) ) then
                return
            end
            -- Check if we have a clear line of sight
            if line_of_sight(body.cost_center_x, body.cost_center_y, brain.grab_target_x, brain.grab_target_y, 1) then
                brain.movement = 1
                brain.rotation = cross(body.dir_x, body.dir_y, dirx, diry)
            end
            if(distance < 60) then
                brain.ability = true -- Activate ability (e.g., attacking)
                brain.movement = 1
                brain.rotation = 1
                end

            -- Avoid walls during the attack        end
    end
end
    

    Attack()  


    -- Wall avoidance is always a fallback
    avoid_walls(body, brain, 60)
    brain.values = {}
    brain.values[1] = body.cost_center_x
    brain.values[2] = body.cost_center_y
    brain.values[3] = retreat
    brain.values[4] = cooldown
    brain.values[5] = cooldownRetr

    return brain
end