local coreFuncs = require("coreFuncs")

local physicsProp = ENGINE_COMPONENTS.scriptComponent.new()

function physicsProp:setup()
    local prop = self.parent
    prop.velocity = {0, 0}
    prop.rotVelocity = 0
    prop.oldPos = table.new(prop.position)
    prop.destroyed = false
end

function physicsProp:collisionCheck(prop, delta)
    if not prop.collidable then return end
    local src = prop.imageComponent.source
    local w, h = src:getWidth(), src:getHeight()
    local propSize = {prop.scale[1]*w, prop.scale[2]*h}
    local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
    --iterate through walls
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if coreFuncs.aabbCollision(propPos, wall.position, propSize, wallSize) then
            prop.position = table.new(prop.oldPos)
            --FIXME crates get stuck on walls!!!
        end
    end
    --iterate through props
    for _, prop2 in ipairs(CurrentScene.props.tree) do
        if prop2.collidable and prop2 ~= prop then
            local propSrc = prop2.imageComponent.source
            local w2, h2 = propSrc:getWidth(), propSrc:getHeight()
            local propSize2 = {prop2.scale[1]*w2, prop2.scale[2]*h2}
            local propPos2 = {prop2.position[1]-propSize2[1]/2, prop2.position[2]-propSize2[2]/2}
            if coreFuncs.aabbCollision(propPos, propPos2, propSize, propSize2) then
                prop.position = table.new(prop.oldPos)
                --pushing props
                if prop.movable and prop2.movable then
                    --calculate push rotation
                    local dx, dy = propPos[1]-propPos2[1], propPos[2]-propPos2[2]
                    local pushRot = math.atan2(dy, dx) + math.pi
                    local vel = math.getVecValue(prop.velocity)
                    prop2.velocity[1] = prop2.velocity[1] + vel*math.cos(pushRot)/prop2.mass*delta
                    prop2.velocity[2] = prop2.velocity[2] + vel*math.sin(pushRot)/prop2.mass*delta
                end
            end
        end
    end
end

function physicsProp:physicsUpdate(delta)
    local prop = self.parent
    --movement
    prop.oldPos = table.new(prop.position)
    prop.position[1] = prop.position[1] + prop.velocity[1]*delta
    prop.position[2] = prop.position[2] + prop.velocity[2]*delta
    prop.rotation = prop.rotation + prop.rotVelocity*delta
    prop.velocity[1] = prop.velocity[1] + (-prop.velocity[1])*8*delta
    prop.velocity[2] = prop.velocity[2] + (-prop.velocity[2])*8*delta
    prop.rotVelocity = prop.rotVelocity + (-prop.rotVelocity)*8*delta
    self:collisionCheck(prop, delta)
    if not prop.destroyed then return end
    --fade away
    prop.scale[1] = prop.scale[1] + 20 * delta
    prop.scale[2] = prop.scale[2] + 20 * delta
    prop.imageComponent.color[4] = prop.imageComponent.color[4] - 25 * delta
    --remove from tree if anim. is complete
    if prop.imageComponent.color[4] <= 0 then
        table.removeValue(CurrentScene.props.tree, prop)
    end
end

return physicsProp