local coreFuncs = require("coreFuncs")
local weaponManager = require("desolation.weapon_manager")
local bulletScript = require("desolation.components.bullet_script")
local particleFuncs = require("desolation.particle_funcs")
local object = require("engine.object")
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local itemScript = require("desolation.components.item.item_script")
local humanoidScript = require("desolation.components.humanoid_script")

local playerScript = table.new(humanoidScript)

function playerScript:movement(delta, player)
    local speed = GetGlobal("p_speed")
    player.moveVelocity = {0, 0}
    --Get input
    if InputManager.inputType == "keyboard" then
        --KEYBOARD
        player.moveVelocity[1] = coreFuncs.boolToNum(InputManager:isPressed("move_right")) - coreFuncs.boolToNum(InputManager:isPressed("move_left"))
        player.moveVelocity[2] = coreFuncs.boolToNum(InputManager:isPressed("move_down")) - coreFuncs.boolToNum(InputManager:isPressed("move_up"))
    elseif InputManager.inputType == "joystick" then
        --JOYSTICK
        local axis1, axis2 = InputManager:getAxis(1), InputManager:getAxis(2)
        if math.abs(axis1) > 0.1 then
            player.moveVelocity[1] = axis1
        end
        if math.abs(axis2) > 0.1 then
            player.moveVelocity[2] = axis2
        end
    end
    --player.moving = math.abs(player.moveVelocity[1]) > 0 or math.abs(player.moveVelocity[2]) > 0
    --Sprinting
    if not player.sprinting then player.sprintSoundPlayed = false end
    --Sprinting
    player.sprintCooldown = player.sprintCooldown - delta
    if Settings.sprint_type == "hold" and InputManager.inputType == "keyboard" then
        player.sprinting = (InputManager:isPressed("sprint") and not Settings.always_sprint) or (player.moving and Settings.always_sprint and not InputManager:isPressed("sprint"))
    else
        if Settings.always_sprint then
            player.sprinting = not InputManager:isPressed("sprint")
        else
            if not player.moving then
                player.sprinting = false
            elseif InputManager:isPressed("sprint") and player.moving then
                player.sprinting = true
            end
        end
    end
    if player.stamina < 0 or player.sprintCooldown > 0 or not player.moving then player.sprinting = false end
    if player.sprinting then
        --play sprint sound
        if not player.sprintSoundPlayed then
            local playerSounds = player.soundManager.script
            playerSounds:playStopSound(Assets.sounds["sprint"])
            player.sprintSoundPlayed = true
        end
        if GetGlobal("inf_stamina") < 1 then player.stamina = player.stamina - 25*delta end
        speed = speed * 1.6
        --make a sprint cooldown
        if player.stamina < 0 then
            player.stamina = 0
            player.sprintCooldown = 3
        end
    end
    --Normalize velocity
    if InputManager.inputType == "keyboard" and InputManager:isPressed({"move_left", "move_right"}) == InputManager:isPressed({"move_up", "move_down"}) and player.moving then
        player.moveVelocity[1] = player.moveVelocity[1] * math.sin(math.pi/4)
        player.moveVelocity[2] = player.moveVelocity[2] * math.sin(math.pi/4)
    end
    player.moveVelocity[1] = player.moveVelocity[1] * speed
    player.moveVelocity[2] = player.moveVelocity[2] * speed
    --Recharge stamina
    if player.sprinting then return end
    player.stamina = player.stamina + 18*delta
    if player.stamina > 100 then player.stamina = 100 end
end

function playerScript:pointTowardsMouse(player)
    local pos = coreFuncs.getRelativePosition(player.position, CurrentScene.camera)
    local x, y
    if InputManager.inputType == "keyboard" then
        x, y = coreFuncs.getRelativeMousePosition()
    elseif InputManager.inputType == "joystick" then
        local axis1, axis2 = InputManager:getAxis(3), InputManager:getAxis(4)
        if math.abs(axis1) > 0.1 then
            x = pos[1] + axis1*50
        else
            x = pos[1] + math.cos(player.rotation)*50
        end
        if math.abs(axis2) > 0.1 then
            y = pos[2] + axis2*50
        else
            y = pos[2] + math.sin(player.rotation)*50
        end
    end
    local dx = x-pos[1] ; local dy = y-pos[2]
    player.rotation = math.atan2(dy, dx)
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
    --Switch slot using joystick
    if InputManager.inputType == "joystick" then
        if InputManager.joystick:isDown(10) and not player.keyPressData.leftSlot then
            player.inventory.previousSlot = player.inventory.slot
            player.inventory.slot = player.inventory.slot - 1
            if player.inventory.slot < 1 then player.inventory.slot = 3 end
        end
        if InputManager.joystick:isDown(11) and not player.keyPressData.rightSlot then
            player.inventory.previousSlot = player.inventory.slot
            player.inventory.slot = player.inventory.slot + 1
            if player.inventory.slot > 3 then player.inventory.slot = 1 end
        end
    end
    --Quick slot switching
    if InputManager:isPressed("w_quickswitch") and not player.keyPressData["q"] and player.inventory.previousSlot then
        local temp = player.inventory.previousSlot
        player.inventory.previousSlot = player.inventory.slot
        player.inventory.slot = temp
    end
    player.keyPressData["q"] = InputManager:isPressed("w_quickswitch")
    if InputManager.inputType == "joystick" then
        player.keyPressData.leftSlot = InputManager.joystick:isDown(10)
        player.keyPressData.rightSlot = InputManager.joystick:isDown(11)
    end
    --Update hand offset
    if oldSlot ~= player.inventory.slot and player.inventory.weapons[oldSlot] ~= player.inventory.weapons[player.inventory.slot] then
        player.handOffset = -15
    end
    --Cancel reload if slot switching is done
    if oldSlot ~= player.inventory.slot then
        player.reloading = false
        local weapon = player.inventory.weapons[player.inventory.previousSlot]
        if weapon then
            local playerSounds = player.soundManager.script
            playerSounds:stopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
        end
    end
end

function playerScript:weaponDropping(player)
    local weapon = player.inventory.weapons[player.inventory.slot]
    if not InputManager:isPressed("drop_weapon") or weapon == nil then return end
    --Create object data
    local itemInstance = object.new(CurrentScene.items)
    itemInstance.name = "weapon"
    itemInstance.scale = {2, 2}
    itemInstance.weaponData = weapon.new()
    itemInstance:addComponent(table.new(itemScript))
    itemInstance.pickupEvent = itemEventFuncs.weaponPickup
    itemInstance.script:load()
    itemInstance.imageComponent.source = Assets.images["weapon_" .. string.lower(weapon.name)]
    --send current magAmmo to players ammunition because i couldnt get it to work
    player.inventory.ammunition[weapon.ammoType] = player.inventory.ammunition[weapon.ammoType] + weapon.magAmmo

    --Set some variables
    itemInstance.position[1] = player.position[1]
    itemInstance.position[2] = player.position[2]
    itemInstance.velocity = 550
    itemInstance.rotVelocity = math.uniform(-1, 1)*math.pi*12 --TODO this could've been better
    itemInstance.realRot = player.rotation

    CurrentScene.items:addChild(itemInstance)
    --Cancel reloading
    player.reloading = false
    if weapon then
        local playerSounds = player.soundManager.script
        if Assets.sounds["reload_" .. string.lower(weapon.name)] then
            playerSounds:stopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
        end
    end
    --Get rid of the held weapon
    player.inventory.weapons[player.inventory.slot] = nil
    --play sound
    local playerSounds = player.soundManager.script
    playerSounds:playStopSound(Assets.sounds["drop"])
end

function playerScript:shootingWeapon(delta, player)
    player.shootTimer = player.shootTimer + delta
    local weapon = player.inventory.weapons[player.inventory.slot]
    if weapon == nil then return end
    local playerSounds = player.soundManager.script
    if (love.mouse.isDown(1) or InputManager:getAxis(6) > 0.4) then
        self:humanoidShootWeapon(weapon)
    end
end

function playerScript:reloadingWeapon(delta, player)
    local weapon = player.inventory.weapons[player.inventory.slot]
    --Returning if no weapon is being held
    if not weapon then return end
    --Returning if: no ammunition is left, the mag is full
    if weapon.magAmmo == weapon.magSize or player.inventory.ammunition[weapon.ammoType] < 1 then return end
    if player.reloading then
        player.reloadTimer = player.reloadTimer + delta
        if player.reloadTimer > weapon.reloadTime then
            player.reloadTimer = 0
            if weapon.weaponType == "auto" then
                player.reloading = false
                --Actual reloading stuff
                local ammoNeeded = weapon.magSize - weapon.magAmmo
                if ammoNeeded > player.inventory.ammunition[weapon.ammoType] then
                    --If the place to fill is greater than the amount of ammunition
                    weapon.magAmmo = weapon.magAmmo + player.inventory.ammunition[weapon.ammoType]
                    player.inventory.ammunition[weapon.ammoType] = 0
                else
                    --..Or if there's more
                    weapon.magAmmo = weapon.magAmmo + ammoNeeded
                    player.inventory.ammunition[weapon.ammoType] = player.inventory.ammunition[weapon.ammoType] - ammoNeeded
                end
            elseif weapon.ammoType == "shotgun" then
                --Actual reloading stuff
                if player.inventory.ammunition[weapon.ammoType] < 1 then
                    --end reload since no more shells are left
                    player.reloading = false
                    player.reloadTimer = weapon.reloadTime
                else
                    --add one shell to weapon
                    player.inventory.ammunition[weapon.ammoType] = player.inventory.ammunition[weapon.ammoType] - 1
                    weapon.magAmmo = weapon.magAmmo + 1
                    --sound effects
                    local playerSounds = player.soundManager.script
                    if weapon.magAmmo == weapon.magSize then
                        playerSounds:playStopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
                        player.reloading = false
                    else
                        playerSounds:playStopSound(Assets.sounds["progress_" .. string.lower(weapon.name)])
                    end
                end
            end
        end
    else
        if InputManager:isPressed("reload") then
            local playerSounds = player.soundManager.script
            if weapon.weaponType == "auto" then
                playerSounds:playStopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
            end
            player.reloading = true
            player.reloadTimer = 0
        end
    end
end

--Engine funcs
function playerScript:load()
    self:humanoidSetup()
    local player = self.parent
    --Player variables
    player.sprintCooldown = 0
    player.sprintSoundPlayed = false
    player.armorAcquired = true
    --TODO Find a better way to handle these key presses?
    player.keyPressData = {
        ["q"] = false;
    }
    player.nearItem = nil
end

function playerScript:update(delta)
    SetGlobal("p_speed", 2000)
    if GamePaused then return end
    local player = self.parent
    self:humanoidUpdate(delta, player)

    if player.health <= 0 then return end
    self:movement(delta, player)
    self:pointTowardsMouse(player)
    self:slotSwitching(player)
    self:weaponDropping(player)
    self:shootingWeapon(delta, player)
    self:reloadingWeapon(delta, player)
end

return playerScript