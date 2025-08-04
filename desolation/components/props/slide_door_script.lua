local coreFuncs = require("coreFuncs")
local slideDoorScript = ENGINE_COMPONENTS.scriptComponent.new()

function slideDoorScript:load()
    local door = self.parent
    door.imageComponent = ENGINE_COMPONENTS.imageComponent.new(door, Assets.mapImages["prop_slide_door"])
    door.imageComponent.layer = 4
    if door.big then
        door.scale = {11, 3.5}
    else
        door.scale = {3.7, 2.3}
    end
    door.moving = false
    door.closeTimer = 0
    door.oldPosition = table.new(door.position)
    door.opening = false
end

function slideDoorScript:update(delta)
    if GamePaused then return end
    local door = self.parent
    if door.locked then
        door.collidable = true
        return
    end
    --TODO add humanoids
    --Measure distance to player
    local distance = coreFuncs.pointDistance(CurrentScene.player.position, door.oldPosition)
    door.collidable = false--distance >= 85
    --Move and make sound
    local moveSpeed = 500
    if distance >= 85 then
        door.closeTimer = door.closeTimer + delta
        if door.closeTimer > 1.6 then
            --Closing
            if door.moving then
                --NOTE might need a close sound effect
                SoundManager:restartSound(Assets.mapSounds["slide_door_open"], Settings.vol_world, door.position, true)
            end
            door.moving = false
            door.position[1] = door.position[1] + moveSpeed*math.cos(door.rotation)*delta
            door.position[2] = door.position[2] + moveSpeed*math.sin(door.rotation)*delta
            if door.position[1] > door.oldPosition[1] then
                door.position[1] = door.oldPosition[1]
            end
            if door.position[2] > door.oldPosition[2] then
                door.position[2] = door.oldPosition[2]
            end
        end
    else
        --Opening
        if not door.moving then
            SoundManager:restartSound(Assets.mapSounds["slide_door_open"], Settings.vol_world, door.position, true)
            door.opening = true
        end
        door.moving = true
        door.closeTimer = 0
    end
    if door.opening then
        door.position[1] = door.position[1] - moveSpeed*math.cos(door.rotation)*delta
        door.position[2] = door.position[2] - moveSpeed*math.sin(door.rotation)*delta
        if door.position[1] < door.oldPosition[1]-128*math.cos(door.rotation) then
            door.position[1] = door.oldPosition[1]-128*math.cos(door.rotation)
            door.opening = false
        end
        if door.position[2] < door.oldPosition[2]-128*math.sin(door.rotation) then
            door.position[2] = door.oldPosition[2]-128*math.sin(door.rotation)
            door.opening = false
        end
    end
end

return slideDoorScript
