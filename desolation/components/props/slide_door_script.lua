local coreFuncs = require("coreFuncs")
local slideDoorScript = ENGINE_COMPONENTS.scriptComponent.new()

function slideDoorScript:load()
    local door = self.parent
    door.imageComponent = ENGINE_COMPONENTS.imageComponent.new(door, Assets.mapImages["prop_slide_door"])
    door.scale = {3.7, 2.3}
end

function slideDoorScript:update(delta)
    local door = self.parent
    --TODO add humanoids
    --Measure distance to player
    local distance = coreFuncs.pointDistance(CurrentScene.player.position, door.position)
    door.collidable = distance >= 85
end

return slideDoorScript
