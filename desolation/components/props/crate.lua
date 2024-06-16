local object = require("engine.object")
local coreFuncs = require("coreFuncs")
local crateScript = ENGINE_COMPONENTS.scriptComponent.new()
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local itemScript = require("desolation.components.item.item_script")
local particleFuncs = require("desolation.particle_funcs")

function crateScript:bulletHitEvent(bullet)
    local crate = self.parent
    crate.health = crate.health - bullet.damage
    crate.velocity[1] = 100*math.cos(bullet.rotation)
    crate.velocity[2] = 100*math.sin(bullet.rotation)
    crate.rotVelocity = math.uniform(-5, 5)
    if crate.health <= 0 then
        crate.destroyed = true
        crate.collidable = false
        --particle effects
        local comp = CurrentScene.bullets.particleComponent
        particleFuncs.createCrateWoodParticles(comp, crate.position)
        --summon loots (if exists)
        if crate.loot == nil then return end
        local mapCreator = CurrentScene.mapCreator
        for _, loot in ipairs(crate.loot) do
            --Create object data
            local itemInstance = object.new(CurrentScene.items)
            itemInstance.name = loot
            itemInstance:addComponent(table.new(itemScript))
            itemInstance.scale = mapCreator.itemData[itemInstance.name].scale
            itemInstance.pickupEvent = itemEventFuncs[mapCreator.itemData[itemInstance.name].pickupEvent]
            itemInstance.script:load()
            --randomize position & rotation
            itemInstance.position = table.new(crate.position)
            itemInstance.velocity = math.uniform(250, 400)
            itemInstance.rotation = math.uniform(0, math.pi)
            itemInstance.realRot = itemInstance.rotation
            CurrentScene.items:addChild(itemInstance)
        end
    end
end

function crateScript:collisionCheck(crate)
    if not crate.collidable then return end
    local src = crate.imageComponent.source
    local w, h = src:getWidth(), src:getHeight()
    local crateSize = {crate.scale[1]*w, crate.scale[2]*h}
    local cratePos = {crate.position[1]-crateSize[1]/2, crate.position[2]-crateSize[2]/2}
    --iterate through walls
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if coreFuncs.aabbCollision(cratePos, wall.position, crateSize, wallSize) then
            crate.position = table.new(crate.oldPos)
            --FIXME crates get stuck on walls!!!
        end
    end
    --iterate through props
    for _, prop in ipairs(CurrentScene.props.tree) do
        if prop.collidable and prop ~= crate then
            local propSrc = prop.imageComponent.source
            local w2, h2 = propSrc:getWidth(), propSrc:getHeight()
            local propSize = {prop.scale[1]*w2, prop.scale[2]*h2}
            local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
            if coreFuncs.aabbCollision(cratePos, propPos, crateSize, propSize) then
                crate.position = table.new(crate.oldPos)
                --pushing crates
                if string.sub(prop.name, 1, 5) == "crate" then
                    --calculate push rotation
                    local dx, dy = cratePos[1]-propPos[1], cratePos[2]-propPos[2]
                    local pushRot = math.atan2(dy, dx) + math.pi
                    prop.velocity[1] = prop.velocity[1] + 20*math.cos(pushRot)
                    prop.velocity[2] = prop.velocity[2] + 20*math.sin(pushRot)
                end
            end
        end
    end
end

function crateScript:load()
    local crate = self.parent
    --load image if nonexistant
    if Assets.mapImages["prop_crate"] == nil then
        Assets.mapImages["prop_crate"] = love.graphics.newImage("desolation/assets/images/props/crate.png")
    end
    crate.imageComponent = ENGINE_COMPONENTS.imageComponent.new(crate, Assets.mapImages["prop_crate"])
    crate.scale = {2.5+coreFuncs.boolToNum(crate.name == "crate_big"), 2.5+coreFuncs.boolToNum(crate.name == "crate_big")}
    crate.destroyed = false
    crate.velocity = {0, 0}
    crate.oldPos = table.new(crate.position)
    crate.rotVelocity = 0
end

function crateScript:update(delta)
    local crate = self.parent
    --movement
    crate.oldPos = table.new(crate.position)
    crate.position[1] = crate.position[1] + crate.velocity[1]*delta
    crate.position[2] = crate.position[2] + crate.velocity[2]*delta
    crate.rotation = crate.rotation + crate.rotVelocity*delta
    crate.velocity[1] = crate.velocity[1] + (-crate.velocity[1])*8*delta
    crate.velocity[2] = crate.velocity[2] + (-crate.velocity[2])*8*delta
    crate.rotVelocity = crate.rotVelocity + (-crate.rotVelocity)*8*delta
    self:collisionCheck(crate)
    if not crate.destroyed then return end
    --fade away
    crate.scale[1] = crate.scale[1] + 20 * delta
    crate.scale[2] = crate.scale[2] + 20 * delta
    crate.imageComponent.color[4] = crate.imageComponent.color[4] - 25 * delta
    --remove from tree if anim. is complete
    if crate.imageComponent.color[4] <= 0 then
        table.removeValue(CurrentScene.props.tree, crate)
    end
end

return crateScript