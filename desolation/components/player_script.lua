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
    --Multiply speed if infinite mode and speed powerup is obtained
    if CurrentScene.currentPowerup == "speed" then
        speed = speed * 1.4
    end
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
    if ((player.stamina < 0 or player.sprintCooldown > 0) and CurrentScene.currentPowerup ~= "speed") or not player.moving then player.sprinting = false end
    if player.sprinting then
        --play sprint sound
        if not player.sprintSoundPlayed then
            SoundManager:restartSound(Assets.sounds["sprint"], Settings.vol_world, player.position, true)
            player.sprintSoundPlayed = true
            if CurrentScene.currentPowerup ~= "speed" then
                player.stamina = player.stamina - 10
            end
        end
        --Decrease stamina
        if GetGlobal("inf_stamina") < 1 and CurrentScene.currentPowerup ~= "speed" then player.stamina = player.stamina - GetGlobal("stamina_drain")*delta end
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
    player.stamina = player.stamina + GetGlobal("stamina_fill")*delta
    if player.stamina > 100 then player.stamina = 100 end
end

function playerScript:leaveTrailParticles(player, delta)
    if not player.moving or CurrentScene.currentPowerup ~= "speed" then
        player.trailTimer = 0
        return
    end
    local cooldown = 0.05
    player.trailTimer = player.trailTimer + delta
    if player.trailTimer > cooldown then
        player.trailTimer = 0
        local particleComp = CurrentScene.bullets.particleComponent
        --ok so apparently I've made particle positions relative to the object, so
        --I can't really use the player's own particle component because it always follows the
        --player around that way
        --So bullets it is lmao, gotta love Polarity Engine
        particleFuncs.createHumanoidTrailParticle(particleComp, player)
    end
end

function playerScript:returnAimAssistTarget(assistType, x, y)
    local playerPos = self.parent.position
    local relativePlayerPos = coreFuncs.getRelativePosition(playerPos, CurrentScene.camera)
    local distance
    local targetData = {math.huge, nil, false} --Distance, object, isNPC?

    if assistType == 1 then --Return the closest target
        --Iterate through NPC's
        for _, npc in ipairs(CurrentScene.npcs.tree) do
            distance = coreFuncs.pointDistance(playerPos, npc.position)
            if distance < targetData[1] then
                targetData = {distance, npc, true}
            end
        end
        --Iterate through props
        for _, prop in ipairs(CurrentScene.props.tree) do
            distance = coreFuncs.pointDistance(playerPos, prop.position)
            if distance < 1000 and distance < targetData[1] and prop.targetable and not targetData[3] then
                targetData = {distance, prop, false}
            end
        end
    else --More advanced, find closest target on where the player is aiming at
        local expectedRotation = math.atan2(y-relativePlayerPos[2], x-relativePlayerPos[1])
        --Iterate through NPC's
        for _, npc in ipairs(CurrentScene.npcs.tree) do
            distance = coreFuncs.pointDistance(playerPos, npc.position)
            x, y = unpack(coreFuncs.getRelativePosition(npc.position, CurrentScene.camera))
            local dx, dy = x-relativePlayerPos[1], y-relativePlayerPos[2]
            local rot = math.atan2(dy, dx)
            if distance < 1000 and distance < targetData[1] and rot > expectedRotation-math.pi/12 and rot < expectedRotation+math.pi/12 then
                targetData = {distance, npc}
            end
        end
        --Iterate through props
        for _, prop in ipairs(CurrentScene.props.tree) do
            distance = coreFuncs.pointDistance(playerPos, prop.position)
            x, y = unpack(coreFuncs.getRelativePosition(prop.position, CurrentScene.camera))
            local dx, dy = x-relativePlayerPos[1], y-relativePlayerPos[2]
            local rot = math.atan2(dy, dx)
            if distance < 1000 and distance < targetData[1] and rot > expectedRotation-math.pi/8 and rot < expectedRotation+math.pi/8 and prop.targetable then
                targetData = {distance, prop}
            end
        end
    end

    return targetData[2]
end

function playerScript:pointTowardsMouse(player, delta)
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
        --Do Aim Assist raycast
        if Settings.controller_aim_assist and (math.abs(axis1) > 0.1 or math.abs(axis2) > 0.1) then
            local target = self:returnAimAssistTarget(2, x, y)
            if player.aimAssistTarget == nil or InputManager:getAxis(6) <= 0.4 or player.aimAssistTarget.health <= 0 then
                player.aimAssistTarget = target
            end
            if player.aimAssistTarget ~= nil then
                x, y = unpack(coreFuncs.getRelativePosition(player.aimAssistTarget.position, CurrentScene.camera))
            end
        end
    end
    --Rotate towards the finalized target
    local dx = x-pos[1] ; local dy = y-pos[2]
    local goal = math.atan2(dy, dx)
    local diff = (goal-player.rotation+math.pi)%(2*math.pi)-math.pi
    player.rotation = player.rotation + diff*18*delta
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
        if weapon ~= nil then
            SoundManager:stopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
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
    local spinDirection = 1
    if math.uniform(0, 1) < 0.5 then
        spinDirection = -1
    end
    itemInstance.rotVelocity = spinDirection*math.pi*math.uniform(8, 14)
    itemInstance.realRot = player.rotation

    CurrentScene.items:addChild(itemInstance)
    --Cancel reloading
    player.reloading = false
    if weapon then
        local src = Assets.sounds["reload_" .. string.lower(weapon.name)]
        if src ~= nil then
            SoundManager:stopSound(Assets.sounds["reload_" .. string.lower(weapon.name)])
        end
    end
    --Get rid of the held weapon
    player.inventory.weapons[player.inventory.slot] = nil
    --play sound
    SoundManager:restartSound(Assets.sounds["drop"], Settings.vol_world, player.position, true)
end

function playerScript:shootingWeapon(delta, player)
    player.shootTimer = player.shootTimer + delta
    local weapon = player.inventory.weapons[player.inventory.slot]
    if weapon == nil then return end
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
                    if weapon.magAmmo == weapon.magSize or player.inventory.ammunition[weapon.ammoType] < 1 then
                        SoundManager:restartSound(Assets.sounds["reload_" .. string.lower(weapon.name)], Settings.vol_world, player.position, true)
                        player.reloading = false
                    else
                        SoundManager:restartSound(Assets.sounds["progress_" .. string.lower(weapon.name)], Settings.vol_world, player.position, true)
                    end
                end
            end
        end
    else
        if InputManager:isPressed("reload") then
            if weapon.weaponType == "auto" then
                local src = Assets.sounds["reload_" .. string.lower(weapon.name)]
                if src ~= nil then
                    SoundManager:restartSound(src, Settings.vol_world, player.position, true)
                end
            end
            player.reloading = true
            player.reloadTimer = 0
        end
    end
end

function playerScript:distantAchivementCheck(player)
    --if Achievements.distant.obtained then return end
    if player.position[1] ~= player.position[1] or player.position[2] ~= player.position[2] then
        SoundManager:restartSound(Assets.sounds["hurt2"], 1)
        player.health = -31
        CurrentScene.gameOver.UIComponent.title.text = Loca.bruhuhuh
        if not Achievements.distant.obtained then
            GiveAchievement("distant")
        end
    end
end

function playerScript:updateLights(delta, player)
    --Primary light
    self.lightRadius = self.lightRadius + (500-150*coreFuncs.boolToNum(player.moving)-self.lightRadius)*2*delta
    Lighter:updateLight(player.primaryLight, player.position[1], player.position[2], self.lightRadius, 0.8, 0.8, 0.8, 0.5)
    --Flashlight
    --Close flashlight if the armor is not acquired (prob unnecessary code though)
    if not player.flashlightAcquired then player.flashlightOn = false end
    if not player.flashlightOn then
        player.flashlight.a = 0
        return
    end
    self.lightFlickerTimer = self.lightFlickerTimer + delta
    if not self.lightFlickered and self.lightFlickerTimer > self.lightFlickerTime then
        self.lightFlickered = true
    end
    if self.lightFlickered then
        if self.lightFlickerTimer > self.lightFlickerTime + 0.05 then
            self.lightFlickered = false
            self.lightFlickerTime = math.uniform(1, 7)
            self.lightFlickerTimer = 0
        end
    end
    local offset = 20
    Lighter:updateLight(player.flashlight, player.position[1]+offset*math.cos(player.rotation), player.position[2]+offset*math.sin(player.rotation), 10000, 1, 1, 1)
    player.flashlight.a = 0.7*coreFuncs.boolToNum(not self.lightFlickered)
    player.flashlight.rotation = player.rotation
end

--Engine funcs
function playerScript:load()
    self:humanoidSetup()
    local player = self.parent
    --Player variables
    player.sprintCooldown = 0
    player.sprintSoundPlayed = false
    player.armorAcquired = true
    player.flashlightAcquired = false
    player.keyPressData = {}
    player.nearItem = nil
    player.aimAssistTarget = nil
    --Light variables
    player.primaryLight = CurrentScene:addLight(player.position[1], player.position[3], 500, 0.8, 0.8, 0.8)
    player.flashlight = CurrentScene:addLight(player.position[1], player.position[2], 100, 1, 1, 1)
    player.flashlight.gradientImage = FlashlightGradientImage

    --player.primaryLight = Lighter:addLight(player.position[1], player.position[2], 350, 0.8, 0.8, 0.8)
    self.lightRadius = 500
    self.lightFlickerTimer = 0
    self.lightFlickerTime = math.uniform(1, 7)
    self.lightFlickered = false
    player.flashlightOn = false
end

function playerScript:update(delta)
    if GamePaused then return end
    local player = self.parent
    self:humanoidUpdate(delta, player)

    if player.health <= 0 then
        player.moveVelocity = {0, 0}
        player.flashlight.a = 0
        return
    end
    self:movement(delta, player)
    self:pointTowardsMouse(player, delta)
    self:leaveTrailParticles(player, delta)
    self:slotSwitching(player)
    self:weaponDropping(player)
    self:shootingWeapon(delta, player)
    self:reloadingWeapon(delta, player)
    self:distantAchivementCheck(player)
    self:updateLights(delta, player)
end

return playerScript