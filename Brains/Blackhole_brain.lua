_G["AdExtra.Black_Hole_Brain"] = function(body)
    local brain = {}
    local cooldown = body.values[1] or 3*120
    local attack = body.values[2] or true
    local cooldown2 = body.values[3] or 3*160
    local bodies = get_visible_bodies(body.id, 200, false)

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

    local ebody,eid = Retrive("Enemy",false,false)


    brain.movement = 1
    brain.rotation = rand_normal() * math.sin(body.age)
    cooldown = cooldown - 1*120
    cooldown2 = cooldown2 - 1*20

    if (cooldown < 0) then
        cooldown = 3*120
        attack = true
    end

    if (attack == true and ebody and cooldown2 > 0) then
        brain.rotation = 1
        brain.movement = 0
        brain.ability = true
    elseif(cooldown2 < 0)then
        attack = false
    end

    brain.values = {}
    brain.values[1] = cooldown
    brain.values[2] = attack
    brain.values[3] = cooldown2
    return brain
end