--local cameraController = require("fdh.components.camera_controller")
local coreFuncs = require("coreFuncs")

local playerScript = {}

function playerScript:movement(delta, player)
    local transform = player.transformComponent

    local speed = GetGlobal("p_speed")
    self.velocity = {x=0, y=0}
    --Get key input
    if love.keyboard.isDown("a") then
        self.velocity.x = self.velocity.x - 1
    end
    if love.keyboard.isDown("d") then
        self.velocity.x = self.velocity.x + 1
    end
    if love.keyboard.isDown("w") then
        self.velocity.y = self.velocity.y - 1
    end
    if love.keyboard.isDown("s") then
        self.velocity.y = self.velocity.y + 1
    end
    --Sprinting
    local sprintMultiplier = 1.6
    player.sprinting = InputManager:isPressed("sprint")
    if player.sprinting then
        self.velocity.x = self.velocity.x * sprintMultiplier
        self.velocity.y = self.velocity.y * sprintMultiplier
    end
    --Normalize velocity
    if math.abs(self.velocity.x) == math.abs(self.velocity.y) then
        self.velocity.x = self.velocity.x * math.sin(math.pi/4)
        self.velocity.y = self.velocity.y * math.sin(math.pi/4)
    end
    player.moving = math.abs(self.velocity.x) > 0 or math.abs(self.velocity.y) > 0
    --Move by velocity
    transform.x = transform.x + (self.velocity.x*speed*delta)
    transform.y = transform.y + (self.velocity.y*speed*delta)
end

function playerScript:pointTowardsMouse(player)
    local mouseX, mouseY = love.mouse.getPosition()
    local pos = coreFuncs.getRelativePosition(player.transformComponent, CurrentScene.camera)
    local dx = mouseX-pos[1] ; local dy = mouseY-pos[2]
    player.transformComponent.rotation = math.atan2(dy, dx)
end

function playerScript:slotSwitching(player)
    local oldSlot = player.inventory.slot
    --Switch slot with number keys
    for i = 1, 3 do
        if InputManager:isPressed("w_slot_" .. tostring(i)) and i ~= player.inventory.slot then
            player.inventory.previousSlot = player.inventory.slot
            player.inventory.slot = i
        end
    end
    --Quick slot switching
    if InputManager:isPressed("w_quickswitch") and not player.keyPressData["q"] and player.inventory.previousSlot then
        local temp = player.inventory.previousSlot
        player.inventory.previousSlot = player.inventory.slot
        player.inventory.slot = temp
    end
    player.keyPressData["q"] = InputManager:isPressed("w_quickswitch")
    --Update hand offset
    if oldSlot ~= player.inventory.slot and player.inventory.weapons[oldSlot] ~= player.inventory.weapons[player.inventory.slot] then
        player.handOffset = -15
    end
    --Cancel reload if slot switching is done
    if oldSlot ~= player.inventory.slot then
        player.reloading = false
        local weapon = player.inventory.weapons[player.inventory.previousSlot]
        --if weapon then
        --    love.audio.stop(self.sounds.sources.reload[weapon.name])
        --end
    end
end

function playerScript:doWalkingAnim(player)
    if not player.moving then return end
    local time = love.timer.getTime()
    local speed = 12
    if player.sprinting then speed = speed + 4 end
    player.animationSizeDiff = math.sin(time*speed)/5
    --Set image component values
    player.transformComponent.scale.x = 4 + player.animationSizeDiff
    player.transformComponent.scale.y = 4 + player.animationSizeDiff
end

--Engine funcs
function playerScript:load()
    local player = self.parent
    local transform = player.transformComponent
    player.imageComponent.source = Assets.images.player.body
    transform.scale = {x=4, y=4}
    --Camera
    --CurrentScene.camera.script = cameraController
    --Script variables
    --Player variables
    player.velocity = {x=0, y=0}
    player.health = 100 ; player.armor = 100
    player.sprinting = false
    player.moving = false
    player.reloading = false
    player.animationSizeDiff = 0
    player.handOffset = 0
    player.inventory = {
        weapons = {nil, nil, nil};
        items = {};
        ammunition = {
            light = 0;
            medium = 0;
            heavy = 0;
        };
        slot = 1;
    }
    player.shootTimer = 0
    player.reloadTimer = 0
    player.keyPressData = {
        ["q"] = false;
    }
end

function playerScript:update(delta)
    if GamePaused then return end

    local player = self.parent
    self:movement(delta, player)
    self:pointTowardsMouse(player)
    self:slotSwitching(player)
    self:doWalkingAnim(player)
end

return playerScript