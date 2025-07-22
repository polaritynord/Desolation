local coreFuncs = require("coreFuncs")
local slideDoorScript = ENGINE_COMPONENTS.scriptComponent.new()

function slideDoorScript:load()
    local door = self.parent
    door.imageComponent = ENGINE_COMPONENTS.imageComponent.new(door, Assets.mapImages["prop_slide_door"])
    door.imageComponent.layer = 4
    door.scale = {3.7, 2.3}
    door.moving = false
    door.closeTimer = 0
    door.oldPosition = table.new(door.position)
end

function slideDoorScript:update(delta)
    local door = self.parent
    if door.locked then
        door.collidable = true
        return
    end
    --TODO add humanoids
    --Measure distance to player
    local distance = coreFuncs.pointDistance(CurrentScene.player.position, door.oldPosition)
    door.collidable = distance >= 85
    --Move and make sound
    local moveSpeed = 500
    if door.collidable then
        door.closeTimer = door.closeTimer + delta
        if door.closeTimer > 2 then
            --Closing
            if door.moving then
                --NOTE might need a close sound effect
                SoundManager:restartSound(Assets.mapSounds["slide_door_open"], Settings.vol_world, door.position, true)
            end
            door.moving = false
            door.position[1] = door.position[1] + moveSpeed*delta
            if door.position[1] > door.oldPosition[1] then
                door.position[1] = door.oldPosition[1]
            end
        end
    else
        --Opening
        if not door.moving then
            SoundManager:restartSound(Assets.mapSounds["slide_door_open"], Settings.vol_world, door.position, true)
        end
        door.moving = true
        door.closeTimer = 0
        door.position[1] = door.position[1] - moveSpeed*delta
        if door.position[1] < door.oldPosition[1]-128 then
            door.position[1] = door.oldPosition[1]-128
        end
    end
end

return slideDoorScript
