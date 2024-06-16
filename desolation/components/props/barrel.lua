--TODO fix repetitive code (make crates and barrels use the same funcs for pushing & collision)

local coreFuncs = require("coreFuncs")
local crateScript = ENGINE_COMPONENTS.scriptComponent.new()

function crateScript:bulletHitEvent(bullet)
    local barrel = self.parent
    --sound effect
    local source = Assets.mapSounds["hit_barrel" .. math.random(1, 3)]
    source:setVolume(Settings.vol_master * Settings.vol_world)
    source:stop() ; source:play()
    barrel.velocity[1] = 100*math.cos(bullet.rotation)
    barrel.velocity[2] = 100*math.sin(bullet.rotation)
end

function crateScript:collisionCheck(barrel)
    if not barrel.collidable then return end
    local src = barrel.imageComponent.source
    local w, h = src:getWidth(), src:getHeight()
    local crateSize = {barrel.scale[1]*w, barrel.scale[2]*h}
    local cratePos = {barrel.position[1]-crateSize[1]/2, barrel.position[2]-crateSize[2]/2}
    --iterate through walls
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if coreFuncs.aabbCollision(cratePos, wall.position, crateSize, wallSize) then
            barrel.position = table.new(barrel.oldPos)
            --FIXME crates get stuck on walls!!!
        end
    end
    --iterate through props
    for _, prop in ipairs(CurrentScene.props.tree) do
        if prop.collidable and prop ~= barrel then
            local propSrc = prop.imageComponent.source
            local w2, h2 = propSrc:getWidth(), propSrc:getHeight()
            local propSize = {prop.scale[1]*w2, prop.scale[2]*h2}
            local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
            if coreFuncs.aabbCollision(cratePos, propPos, crateSize, propSize) then
                barrel.position = table.new(barrel.oldPos)
                --pushing crates
                if string.sub(prop.name, 1, 6) == "barrel" or string.sub(prop.name, 1, 5) == "crate" then
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
    local barrel = self.parent
    --load image if nonexistant
    if Assets.mapImages["prop_barrel"] == nil then
        Assets.mapImages["prop_barrel"] = love.graphics.newImage("desolation/assets/images/props/barrel.png")
    end
    --load hit sounds
    for i = 1, 3 do
        if Assets.mapSounds["hit_barrel" .. i] == nil then
            Assets.mapSounds["hit_barrel" .. i] = love.audio.newSource("desolation/assets/sounds/hit_barrel" .. i .. ".wav", "static")
        end
    end
    barrel.imageComponent = ENGINE_COMPONENTS.imageComponent.new(barrel, Assets.mapImages["prop_barrel"])
    barrel.scale = {2.5, 2.5}
    barrel.velocity = {0, 0}
    barrel.oldPos = table.new(barrel.position)
end

function crateScript:update(delta)
    local barrel = self.parent
    --movement
    barrel.oldPos = table.new(barrel.position)
    barrel.position[1] = barrel.position[1] + barrel.velocity[1]*delta
    barrel.position[2] = barrel.position[2] + barrel.velocity[2]*delta
    barrel.velocity[1] = barrel.velocity[1] + (-barrel.velocity[1])*8*delta
    barrel.velocity[2] = barrel.velocity[2] + (-barrel.velocity[2])*8*delta
    self:collisionCheck(barrel)
end

return crateScript