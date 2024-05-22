local coreFuncs = require("coreFuncs")
local weaponManager = require("fdh.weapon_manager")
local weaponItemScript = require("fdh.components.weapon_item")
local object = require("engine.object")

local playerScript = {}

function playerScript:movement(delta, player)
    local transform = player.transformComponent

    local speed = GetGlobal("p_speed")
    local slippiness = GetGlobal("slippiness")
    player.velocity.x = player.velocity.x + (-player.velocity.x)*slippiness*delta
    player.velocity.y = player.velocity.y + (-player.velocity.y)*slippiness*delta
    --Get key input
    if InputManager:isPressed("move_left") then
        player.velocity.x = -1
    end
    if InputManager:isPressed("move_right") then
        player.velocity.x = 1
    end
    if InputManager:isPressed("move_up") then
        player.velocity.y = -1
    end
    if InputManager:isPressed("move_down") then
        player.velocity.y = 1
    end
    player.moving = InputManager:isPressed({"move_left", "move_right", "move_up", "move_down"})
    --Sprinting
    player.sprinting = InputManager:isPressed("sprint")
    if player.sprinting then
        speed = speed * 1.6
    end
    --Normalize velocity
    if InputManager:isPressed({"move_left", "move_right"}) == InputManager:isPressed({"move_up", "move_down"}) and player.moving then
        player.velocity.x = player.velocity.x * math.sin(math.pi/4)
        player.velocity.y = player.velocity.y * math.sin(math.pi/4)
    end
    --Move by velocity
    transform.x = transform.x + (player.velocity.x*speed*delta)
    transform.y = transform.y + (player.velocity.y*speed*delta)
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

function playerScript:weaponDropping(player)
    local weapon = player.inventory.weapons[player.inventory.slot]
    if not InputManager:isPressed("drop_weapon") or not weapon then return end
    --Create new weaponItem instance & pass values to it
    --local itemInstance = weaponItem.new(weapon.new(), CurrentScene.item)
    --itemInstance.position = player:getPosition()
    --itemInstance.velocity = 550
    --itemInstance.rotVelocity = math.uniform(-1, 1)*math.pi*12 --TODO this could've been better
    --itemInstance.realRot = player.transformComponent.rotation

    --Create object data
    local itemInstance = object.new(CurrentScene.items)
    local script = table.new(weaponItemScript)
    local playerPos = player:getPosition()
    itemInstance.weaponData = weapon.new()
    script.parent = itemInstance
    itemInstance.script = script
    script:load()

    --Set some variables
    itemInstance.transformComponent.x = playerPos.x
    itemInstance.transformComponent.y = playerPos.y
    script.velocity = 550
    script.rotVelocity = math.uniform(-1, 1)*math.pi*12 --TODO this could've been better
    script.realRot = player.transformComponent.rotation

    CurrentScene.items:addChild(itemInstance)
    --Get rid of the held weapon
    player.inventory.weapons[player.inventory.slot] = nil
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
    --TODO Find a better way to handle these key presses?
    player.keyPressData = {
        ["q"] = false;
    }
    --Starter weapon
    weaponManager:load()
    player.inventory.weapons[1] = weaponManager.Pistol.new()
    player.inventory.weapons[1].magAmmo = 18
    player.inventory.ammunition.light = 78
    if player.name == "player2" then
        player.transformComponent.x = 100
    end
end

function playerScript:update(delta)
    if GamePaused then return end

    local player = self.parent
    self:movement(delta, player)
    self:pointTowardsMouse(player)
    self:slotSwitching(player)
    self:doWalkingAnim(player)
    self:weaponDropping(player)
    --Update hand offset
    player.handOffset = player.handOffset + (-player.handOffset) * 20 * delta
end

return playerScript