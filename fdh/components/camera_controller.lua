local cameraController = {}

function cameraController:update(delta)
    local camTransform = CurrentScene.camera.transformComponent
    local player = CurrentScene.player
    --Non-freecam (follow player around)
    if GetGlobal("freecam") < 1 then
        local dx = player.transformComponent.x - camTransform.x
        local dy = player.transformComponent.y - camTransform.y
        camTransform.x = camTransform.x + dx*8*delta
        camTransform.y = camTransform.y + dy*8*delta
    else
        --Freecam
    end
end

return cameraController