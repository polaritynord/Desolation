local coreFuncs = require("coreFuncs")
local tileScript = ENGINE_COMPONENTS.scriptComponent.new()

function tileScript:update(delta)
    local tile = self.parent
    --Check player
    local pos = CurrentScene.player.position
    if coreFuncs.aabbCollision(pos, tile.position, {48, 48}, {2048, 2048}) then
        print(delta)
    end
end

return tileScript