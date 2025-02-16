_G["AdExtra.Cracker"] = function(body)
    ---@type brain

    local bodies = get_visible_bodies(body.id, 500, false)
    local brain = {}

    local function hypot(b1, b2)
        local b1x, b1y = b1.cost_center_x, b1.cost_center_y
        local b2x, b2y = b2.cost_center_x, b2.cost_center_y

        return math.sqrt((b2x - b1x)^2 + (b2y - b1y)^2)
    end

    local function getEnemy()
        for i, v in ipairs(bodies) do
            if v.team ~= body.team then
            return i, v
            end
        end
        
    end
    brain.movement = 0.1
    brain.rotation = 0.2 * rand_normal() * math.sin(0.7 * body.mass)
    brain.ability = false
    local function sneekAttack()
        local EnemyId, Enemybody = getEnemy()
        if Enemybody then
            -- if you are behind the enemy
                        -- Target enemy position
            brain.grab_target_x = Enemybody.cost_center_x
            brain.grab_target_y = Enemybody.cost_center_y
            
                        -- Direction to the target
            local dirx = brain.grab_target_x - body.cost_center_x
            local diry = brain.grab_target_y - body.cost_center_y
                                                                                                                                                               
            brain.rotation = cross(body.dir_x, body.dir_y, dirx, diry)

            local angle = math.atan2(Enemybody.cost_center_y - body.cost_center_y, Enemybody.cost_center_x - body.cost_center_x)
            local enemy_angle = math.atan2(Enemybody.dir_y, Enemybody.dir_x)
            if math.abs((angle - (enemy_angle + math.pi) + math.pi) % (2 * math.pi) - math.pi) > math.pi * 3 / 4 then
                
                local offset = 20  -- Adjust this to control how far behind the enemy the circle appears
                local back_x = Enemybody.com_x - math.cos(enemy_angle) * offset
                local back_y = Enemybody.com_y - math.sin(enemy_angle) * offset

                draw_circle(back_x,back_y,4,1,1,1,1)
                brain.ability = true
                brain.movement = 1
                brain.rotation = cross(body.dir_x, body.dir_y, dirx, diry)
            else
                local offset_back = 30  -- Distance behind the enemy
                local offset_side = 10  -- Distance to the right -- Adjust this to control how far behind the enemy the circle appears
                local back_x = Enemybody.com_x - math.cos(enemy_angle) * offset_back
                local back_y = Enemybody.com_y - math.sin(enemy_angle) * offset_back

                local side_x = back_x + math.sin(enemy_angle) * offset_side
                local side_y = back_y - math.cos(enemy_angle) * offset_side

                local dirx = side_x - body.cost_center_x
                local diry = side_y - body.cost_center_y
                draw_circle(side_x,side_y,4,1,0,0,1)

                brain.movement = 1
                brain.rotation = cross(body.dir_x, body.dir_y, dirx, diry)

            end
        end
    end

  

    sneekAttack()

    avoid_walls(body, brain, 60)
    brain.values = {}

    return brain
end
