local coreFuncs = require "coreFuncs"
local lootSpawner = ENGINE_COMPONENTS.scriptComponent.new()

function lootSpawner:determineCratePos()
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

function lootSpawner:load()
    --Spawn beginning crates
    local beginningCrateAmount = 15
    for i = 1, beginningCrateAmount do
        local cratePos = self:determineCratePos()
        local crateType = "crate"
        if math.uniform(0, 6) <= 3 then
            crateType = "crate_big"
        end
        local propData = {
            crateType, cratePos, math.uniform(0, math.pi*2), {}
        }
        CurrentScene.mapCreator.script:spawnProp(propData, CurrentScene.mapCreator.props)
    end
end

function lootSpawner:update(delta)

end

return lootSpawner