local coreFuncs = require "coreFuncs"
local cameraController = ENGINE_COMPONENTS.scriptComponent.new()

function cameraController:idleCamera(delta, camera, player)
    if player.moving or GetGlobal("freecam") > 0 or not Settings.camera_sway then
        self.idleTimer = 0
        return
    end
    self.idleTimer = self.idleTimer + delta
    --if self.idleTimer < 3 then return end

    local speed = 1
    local intensity = 10
    local smoothness = 2.5

    local x = player.position[1] + math.cos((self.idleTimer)*speed)*intensity
    local y = player.position[2] + math.sin((self.idleTimer)*speed)*intensity
    camera.position[1] = camera.position[1] + (x-camera.position[1])*smoothness*delta
    camera.position[2] = camera.position[2] + (y-camera.position[2])*smoothness*delta
end

function cameraController:movement(delta, camera, player)
    if GetGlobal("freecam") < 1 then
        --Non-freecam (follow player around)
        local peekX = coreFuncs.boolToNum(InputManager:isPressed("peek"))*math.cos(player.rotation)*300
        local peekY = coreFuncs.boolToNum(InputManager:isPressed("peek"))*math.sin(player.rotation)*300
        local dx = player.position[1]+peekX - camera.position[1]
        local dy = player.position[2]+peekY - camera.position[2]
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
    if player.sprinting and GetGlobal("freecam") < 1 and player.moving then
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
    self.idleTimer = 0
end

function cameraController:update(delta)
    if GamePaused or CurrentScene.name ~= "Game" then return end
    local player = CurrentScene.player
    self:movement(delta, self.parent, player)
    self:updateZoom(delta, self.parent, player)
    self:idleCamera(delta, self.parent, player)
end

return cameraController