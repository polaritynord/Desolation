local coreFuncs = require "coreFuncs"
local cameraController = ENGINE_COMPONENTS.scriptComponent.new()

function cameraController:idleCamera(delta, camera, player)
    if player.moving or GetGlobal("freecam") > 0 or not Settings.camera_sway then
        self.idleTimer = 0
        return
    end
    self.idleTimer = self.idleTimer + delta
    --if self.idleTimer < 3 then return end (uncomment this if you dont want the camera sway to show up instantly after stopping)

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
        local mx, my = coreFuncs.getRelativeMousePosition()
        local dx = player.position[1] - camera.position[1]
        local dy = player.position[2] - camera.position[2]
        local weapon = player.inventory.weapons[player.inventory.slot]
        --Peeking
        if Settings.experimental_peeking and weapon ~= nil then
            if InputManager.inputType == "keyboard" then
                dx = dx + (mx-480)*weapon.aimRange
                dy = dy + (my-270)*weapon.aimRange
            else --Joystick peeking
                dx = dx + InputManager:getAxis(3, 0.15)*weapon.aimRange*300
                dy = dy + InputManager:getAxis(4, 0.15)*weapon.aimRange*300
            end
        end
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
    camera.zoom = camera.zoom + (camera.realZoom-camera.zoom) * self.zoomSmoothness * delta
end

function cameraController:mapBoundaryCheck(camera)
    local camBoundaries = CurrentScene.mapCreator.cameraBoundaries
    if camBoundaries == nil or GetGlobal("freecam") > 0 then return end
    --X left
    if camera.position[1] < camBoundaries[1][1] then
        camera.position[1] = camBoundaries[1][1]
    end
    --X right
    if camera.position[1] > camBoundaries[1][2] then
        camera.position[1] = camBoundaries[1][2]
    end
    --Y up
    if camera.position[2] < camBoundaries[2][1] then
        camera.position[2] = camBoundaries[2][1]
    end
    --Y down
    if camera.position[2] > camBoundaries[2][2] then
        camera.position[2] = camBoundaries[2][2]
    end
end

--Engine funcs
function cameraController:load()
    self.parent.zoom = 1
    self.parent.realZoom = 1
    self.playerManualZoom = 1
    self.zoomSmoothness = 5
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
    self:mapBoundaryCheck(self.parent)
end

return cameraController