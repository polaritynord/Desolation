local coreFuncs = require "coreFuncs"
local openareaManager = ENGINE_COMPONENTS.scriptComponent.new()

function openareaManager:determineCratePos()
    local playerPos = CurrentScene.player.position
    local cratePos = {
        math.uniform(-2200, 2200), math.uniform(-1200, 1200)
    }
    while true do
        local d = coreFuncs.pointDistance(cratePos, playerPos)
        if d > 300 then
            return cratePos
        end
        cratePos = {
            math.uniform(-2200, 2200), math.uniform(-1200, 1200)
        }
    end
end

function openareaManager:load()
    --Spawn beginning crates
    local beginningCrateAmount = 15
    for _ = 1, beginningCrateAmount do
        local cratePos = self:determineCratePos()
        local crateType = "crate"
        if math.random(0, 6) <= 3 then
            crateType = "crate_big"
        end
        local propData = {
            crateType, cratePos, math.uniform(0, math.pi*2),
            {
                {"loot", {"dynamic_loot"}}
            }
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    --Spawn beginning barrels
    local beginningBarrelAmount = 9
    for _ = 1, beginningBarrelAmount do
        local cratePos = self:determineCratePos()
        local propData = {
            "barrel", cratePos, math.uniform(0, math.pi*2), {}
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    --Spawn beginning explosive barrels
    local beginningExplosiveBarrelAmount = 6
    for _ = 1, beginningExplosiveBarrelAmount do
        local cratePos = self:determineCratePos()
        local propData = {
            "explosive_barrel", cratePos, math.uniform(0, math.pi*2), {}
        }
        CurrentScene.mapCreator.script:spawnProp(propData)
    end
    CurrentScene.camera.script.playerManualZoom = 0.8
    CurrentScene.camera.zoom = 4
    CurrentScene.camera.script.zoomSmoothness = 2.3
end

function openareaManager:update(delta)

end

return openareaManager