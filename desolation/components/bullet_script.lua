local coreFuncs = require("coreFuncs")
local imageComponent = require("engine.components.image_component")
local particleFuncs = require("desolation.particle_funcs")

local bulletScript = ENGINE_COMPONENTS.scriptComponent.new()

function bulletScript:collisionCheck(bullet)
    local size = {12, 6}
    for i, pos in ipairs(bullet.oldPositions) do
        local bulletPos = {pos[1]-size[1]/2, pos[2]-size[2]/2}
        --iterate through walls
        for _, wall in ipairs(CurrentScene.walls.tree) do
            local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
            if coreFuncs.aabbCollision(bulletPos, wall.position, size, wallSize) then
                --remove bullet
                table.removeValue(CurrentScene.bullets.tree, bullet)
                --create particles (TODO: particle setting)
                local particleComp = CurrentScene.bullets.particleComponent
                particleFuncs.createWallHitParticles(particleComp, bullet, i, wall.material)
                --particleFuncs.createBulletHoleParticles(particleComp, bullet, i)
            end
        end
        --iterate through props
        for _ ,prop in ipairs(CurrentScene.props.tree) do
            if prop.collidable then
                local src = prop.imageComponent.source
                local w, h = src:getWidth(), src:getHeight()
                local propSize = {prop.scale[1]*w, prop.scale[2]*h}
                local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
                if coreFuncs.aabbCollision(bulletPos, propPos, size, propSize) then
                    --remove bullet
                    table.removeValue(CurrentScene.bullets.tree, bullet)
                    --create particles (TODO: particle setting)
                    local particleComp = CurrentScene.bullets.particleComponent
                    particleFuncs.createWallHitParticles(particleComp, bullet, i, prop.material)
                    --bullet hit event
                    if prop.script.bulletHitEvent ~= nil then
                        prop.script:bulletHitEvent(bullet)
                    end
                end
            end
        end
    end
end

function bulletScript:load()
    local bullet = self.parent
    bullet.imageComponent = imageComponent.new(bullet, Assets.images.bullet)
    bullet.imageComponent.layer = 2
    bullet.timer = 0
    bullet.lifetime = 1
    bullet.oldPositions = {}
end

function bulletScript:update(delta)
    local bullet = self.parent
    bullet.imageComponent.color = {Settings.brightness, Settings.brightness, Settings.brightness, 1}
    bullet.timer = bullet.timer + delta
    --Check for despawn
    if bullet.timer > bullet.lifetime then
        table.removeValue(CurrentScene.bullets.tree, bullet)
        return
    end
    --Create old positions list
    bullet.oldPositions[#bullet.oldPositions+1] = {bullet.position[1], bullet.position[2]}
    if #bullet.oldPositions > 3 then
        table.remove(bullet.oldPositions, 1)
    end
    --Movement
    bullet.position[1] = bullet.position[1] + math.cos(bullet.rotation)*bullet.speed*delta
    bullet.position[2] = bullet.position[2] + math.sin(bullet.rotation)*bullet.speed*delta
    self:collisionCheck(bullet)
end

return bulletScript