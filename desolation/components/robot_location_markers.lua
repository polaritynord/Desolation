local coreFuncs = require "coreFuncs"
local robotLocationMarkers = ENGINE_COMPONENTS.scriptComponent.new()

local function drawMarkers(comp)
    for _, robot in ipairs(CurrentScene.npcs.tree) do
        --check if enemy is in sight, if it is, skip the drawing
        local relativePos = coreFuncs.getRelativePosition(robot.position, CurrentScene.camera)
        local inSight = (relativePos[1] > 0 and relativePos[1] < 960) and (relativePos[2] > 0 and relativePos[2] < 540)
        if inSight then goto skipRobot end
        --calculate the angle between camera and robot
        local dx, dy = CurrentScene.camera.position[1]-robot.position[1], CurrentScene.camera.position[2]-robot.position[2]
        local angle = math.atan2(dy, dx)
        local w, h = Assets.images["hud_hitmarker"]:getDimensions()
        love.graphics.setColor(1, 1, 1, 0.5)
        love.graphics.draw(
            Assets.images["hud_hitmarker"], 480-math.cos(angle)*180, 270-math.sin(angle)*180, angle, 1, 3, w/2, h/2
        )
        love.graphics.setColor(1, 1, 1, 1)
        ::skipRobot::
    end
end

function robotLocationMarkers:load()
    self.parent.imageComponent.draw = drawMarkers
end

return robotLocationMarkers