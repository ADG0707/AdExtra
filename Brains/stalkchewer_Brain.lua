_G["AdExtra.stalkchewer"] = function(body)
    ---@type brain
    
    local bodies = get_visible_bodies(body.id, 500, false)
   -- draw_circle(body.com_x,body.com_y,500,0,0,0.3,0.1)
    local brain = {}
    local cooldown = body.values[1] or 0

    if cooldown > 0 then
        cooldown = math.max(0, cooldown - 1)
    end




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

    local function getBackPos(angdiff,enemy_angle)
        local b = math.abs((angdiff - (enemy_angle + math.pi) + math.pi) % (2 * math.pi) - math.pi) < math.pi * 3 / 5 
        return b
    end

    local function flee()
        brain.movement = -1
        brain.rotation = cross(body.dir_x, body.dir_y, body.wall_dx, body.wall_dy)
        local back_x = body.com_x + 2
        local back_y = body.com_y +2
    end
    local function sneekAttack()
        local EnemyId, Enemybody = getEnemy()
        if Enemybody then

           -- draw_circle(Enemybody.com_x,Enemybody.com_y,4,0,0,0,1)


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
            
            
            
            if getBackPos(angle,enemy_angle) == true and body.wall_dist < 200 and cooldown == 0 then
                brain.ability = true

                local offset = 20  -- Adjust this to control how far behind the enemy the circle appears
                local back_x = Enemybody.com_x - math.cos(enemy_angle) * offset
                local back_y = Enemybody.com_y - math.sin(enemy_angle) * offset

               -- draw_circle(back_x,back_y,4,1,1,1,1)
                brain.movement = 1
                brain.rotation = cross(body.dir_x, body.dir_y, dirx, diry)
                if body.wall_dist > 170 then
                cooldown = 1000  -- Reset cooldown after successful attack
                end
            else
                flee()
            end
        else
        flee()

        end
    end

  

    sneekAttack()
    brain.values = {}
    brain.values[1] = cooldown

    return brain
end
