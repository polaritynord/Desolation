local coreFuncs = require("coreFuncs")
local hitmarkerScript = require("desolation.components.hitmarker_script")
local object = require("engine.object")

local humanoidScript = ENGINE_COMPONENTS.scriptComponent.new()

function humanoidScript:collisionCheck(delta, humanoid)
    local size = {48, 48}
    local humanoidPos = {humanoid.position[1]-size[1]/2, humanoid.position[2]-size[2]/2}
    --iterate through walls
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if coreFuncs.aabbCollision(humanoidPos, wall.position, size, wallSize) then
            humanoid.position = table.new(humanoid.oldPos)
        end
    end
    --iterate through props
    for _, prop in ipairs(CurrentScene.props.tree) do
        if prop.collidable then
            local src = prop.imageComponent.source
            local w, h = src:getWidth(), src:getHeight()
            local propSize = {prop.scale[1]*w, prop.scale[2]*h}
            local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
            if coreFuncs.aabbCollision(humanoidPos, propPos, size, propSize) then
                humanoid.position = table.new(humanoid.oldPos)
                --pushing crates
                if prop.movable then
                    --calculate push rotation
                    local dx, dy = humanoidPos[1]-propPos[1], humanoidPos[2]-propPos[2]
                    local pushRot = math.atan2(dy, dx) + math.pi
                    local playerSpeed = 140 --NOTE speed??
                    if humanoid.sprinting then playerSpeed = playerSpeed*1.6 end
                    local vel =  math.getVecValue(humanoid.moveVelocity)/140
                    prop.velocity[1] = prop.velocity[1] + vel*math.cos(pushRot)*playerSpeed/prop.mass*delta*100
                    prop.velocity[2] = prop.velocity[2] + vel*math.sin(pushRot)*playerSpeed/prop.mass*delta*100
                end
            end
        end
    end
end

function humanoidScript:humanoidUpdate(delta, humanoid)
    --Update hand offset
    humanoid.handOffset = humanoid.handOffset + (-humanoid.handOffset) * 20 * delta
    --movement
    humanoid.oldPos = table.new(humanoid.position)
    humanoid.position[1] = humanoid.position[1] + (humanoid.velocity[1]*delta) + (humanoid.moveVelocity[1]*delta)
    humanoid.position[2] = humanoid.position[2] + (humanoid.velocity[2]*delta) + (humanoid.moveVelocity[2]*delta)
    humanoid.velocity[1] = humanoid.velocity[1] + (-humanoid.velocity[1])*8*delta
    humanoid.velocity[2] = humanoid.velocity[2] + (-humanoid.velocity[2])*8*delta
    self:collisionCheck(delta, humanoid)
    self:doWalkingAnim(humanoid)
    if humanoid.health > 0 then return end
    --fade away
    humanoid.scale[1] = humanoid.scale[1] + 20 * delta
    humanoid.scale[2] = humanoid.scale[2] + 20 * delta
    humanoid.imageComponent.color[4] = humanoid.imageComponent.color[4] - 25 * delta
    humanoid.hand.imageComponent.color[4] = humanoid.imageComponent.color[4]
end

function humanoidScript:doWalkingAnim(humanoid)
    if not humanoid.moving then return end
    local time = love.timer.getTime()
    local speed = 12
    if humanoid.sprinting then speed = speed + 4 end
    humanoid.animationSizeDiff = math.sin(time*speed)/5
    --Set image component values
    humanoid.scale[1] = 4 + humanoid.animationSizeDiff
    humanoid.scale[2] = 4 + humanoid.animationSizeDiff
end

function humanoidScript:damage(amount, sourcePosition)
    local humanoid = self.parent
    if humanoid.name == "player" and GetGlobal("god") > 0 then return end
    if humanoid.name == "player" then
        --create hitmarker
        local hitmarkerInstance = object.new(CurrentScene.hud.tree)
        hitmarkerInstance:addComponent(table.new(hitmarkerScript))
        hitmarkerInstance.script:load()
        local rotation = math.atan2(sourcePosition[2]-CurrentScene.camera.position[2], sourcePosition[1]-CurrentScene.camera.position[1]) + math.pi
        hitmarkerInstance.UIComponent.img.rotation = rotation
        hitmarkerInstance.UIComponent.img.position = {
            480-math.cos(rotation)*70,
            270-math.sin(rotation)*70
        }
        CurrentScene.hud:addChild(hitmarkerInstance)
    end
    --damage humanoid
    if humanoid.armor > amount then
        humanoid.armor = humanoid.armor - amount
        return
    elseif humanoid.armor > 0 then
        amount = amount - humanoid.armor
        humanoid.armor = 0
    end
    humanoid.health = humanoid.health - amount
end

function humanoidScript:explosionEvent(position, radius, intensity)
    local humanoid = self.parent
    local distance = coreFuncs.pointDistance(position, humanoid.position)
    if distance > radius then return end
    --add up velocity
    local dx, dy = humanoid.position[1]-position[1], humanoid.position[2]-position[2]
    local rot = math.atan2(dy, dx)
    humanoid.velocity[1] = humanoid.velocity[1] + math.cos(rot)*intensity*(radius/distance)*100
    humanoid.velocity[2] = humanoid.velocity[2] + math.sin(rot)*intensity*(radius/distance)*100
    --hurt player
    local damageAmount = 2*(radius/distance)*intensity
    self:damage(damageAmount, position)
    --screen shake (if humanoid is player)
    if humanoid.name ~= "player" then return end
    if Settings.screen_shake and GetGlobal("freecam") < 1 then
        local camera = CurrentScene.camera
        local temp = {-1, 1}
        local max = intensity*(radius/distance)
        camera.position[1] = camera.position[1] + temp[math.random(1,2)]*max
        camera.position[2] = camera.position[2] + temp[math.random(1,2)]*max
    end
end

function humanoidScript:humanoidSetup()
    local humanoid = self.parent
    humanoid.imageComponent.source = Assets.images["player_body"]
    humanoid.velocity = {0, 0}
    humanoid.moveVelocity = {0, 0}
    humanoid.health = 100
    humanoid.armor = 100
    humanoid.stamina = 100
    humanoid.scale = {4, 4}
    humanoid.reloading = false
    humanoid.moving = false
    humanoid.sprinting = false
    humanoid.inventory = {
        weapons = {nil, nil, nil};
        items = {};
        grenades = 3;
        ammunition = {
            light = 0;
            medium = 0;
            revolver = 0;
            shotgun = 0;
        };
        slot = 1;
    }
    humanoid.shootTimer = 0
    humanoid.reloadTimer = 0
    humanoid.oldPos = table.new(humanoid.position)
    humanoid.animationSizeDiff = 0
    humanoid.handOffset = 0
end

return humanoidScript