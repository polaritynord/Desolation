local cameraController = {}

function cameraController:movement(delta, camTransform, player)
    if GetGlobal("freecam") < 1 then
        --Non-freecam (follow player around)
        local dx = player.transformComponent.x - camTransform.x
        local dy = player.transformComponent.y - camTransform.y
        camTransform.x = camTransform.x + dx*8*delta
        camTransform.y = camTransform.y + dy*8*delta
    else
        --Freecam
    end
end

function cameraController:updateZoom(delta, camera, player)
    --Zoom in slightly by sprinting
    if player.sprinting then
        camera.realZoom = self.playerManualZoom + 0.035
    else
        camera.realZoom = self.playerManualZoom
    end
    --Change zoom smoothly
    camera.zoom = camera.zoom + (camera.realZoom-camera.zoom) * 5 * delta
end

--Engine funcs
function cameraController:load()
    self.parent.zoom = 1
    self.parent.realZoom = 1
    self.playerManualZoom = 1
end

function cameraController:update(delta)
    local player = CurrentScene.player
    local camTransform = self.parent.transformComponent
    self:movement(delta, camTransform, player)
    self:updateZoom(delta, self.parent, player)
end

return cameraController