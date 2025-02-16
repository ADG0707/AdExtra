
_G["AdExtra.Heilakorbius"] = function(body)
    ---@type brain
    
    local bodies = get_visible_bodies(body.id, 500, false)
   draw_circle(body.cost_center_x,body.cost_center_y,1,0,0,0.3,0.1)
    local brain = {}





    local function hypot(b1, b2)
        local b1x, b1y = b1.cost_center_x, b1.cost_center_y
        local b2x, b2y = b2.cost_center_x, b2.cost_center_y

        return math.sqrt((b2x - b1x)^2 + (b2y - b1y)^2)
    end

    local function getEnemy()
        for i, v in ipairs(bodies) do
            if v.team ~= body.team then
                if hypot(body,v) < 40 then
                    return i, v
                end
            end
        end
        
    end

    if body.wall_dist > 10 then
        brain.movement = -1
        brain.rotation = cross(body.dir_x, body.dir_y, body.wall_dx, body.wall_dy)
    end
    
    local enemyid,enemybody = getEnemy()
    if enemybody then
        brain.movement = 1
        brain.ability = true

    else
    brain.movement = 0.1
    brain.ability = false
    end





    brain.values = {}

    return brain
end
