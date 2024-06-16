local coreFuncs = require("coreFuncs")
local crateScript = ENGINE_COMPONENTS.scriptComponent.new()

function crateScript:bulletHitEvent(bullet)
    local crate = self.parent
    crate.health = crate.health - bullet.damage
    crate.velocity[1] = 100*math.cos(bullet.rotation)
    crate.velocity[2] = 100*math.sin(bullet.rotation)
    if crate.health <= 0 then
        crate.destroyed = true
        crate.collidable = false
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
end

function crateScript:update(delta)
    local crate = self.parent
    --movement
    crate.position[1] = crate.position[1] + crate.velocity[1]*delta
    crate.position[2] = crate.position[2] + crate.velocity[2]*delta
    crate.velocity[1] = crate.velocity[1] + (-crate.velocity[1])*8*delta
    crate.velocity[2] = crate.velocity[2] + (-crate.velocity[2])*8*delta
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