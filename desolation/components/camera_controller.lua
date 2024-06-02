local cameraController = {}

function cameraController:movement(delta, camera, player)
    if GetGlobal("freecam") < 1 then
        --Non-freecam (follow player around)
        local dx = player.position[1] - camera.position[1]
        local dy = player.position[2] - camera.position[2]
        camera.position[1] = camera.position[1] + dx*8*delta
        camera.position[2] = camera.position[2] + dy*8*delta
    else
        --Freecam
        local mx, my = love.mouse.getPosition()
        if love.mouse.isDown(3) then
            camera.position[1] = camera.position[1] + (self.oldMouseX-mx)/camera.zoom
            camera.position[2] = camera.position[2] + (self.oldMouseY-my)/camera.zoom
        end
        self.oldMouseX = mx
        self.oldMouseY = my
    end
end

function cameraController:updateZoom(delta, camera, player)
    --Zoom in slightly by sprinting
    if player.sprinting and GetGlobal("freecam") < 1 then
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
    self.oldMouseX = 0
    self.oldMouseY = 0
end

function cameraController:update(delta)
    if GamePaused then return end
    local player = CurrentScene.player
    self:movement(delta, self.parent, player)
    self:updateZoom(delta, self.parent, player)
end

return cameraController