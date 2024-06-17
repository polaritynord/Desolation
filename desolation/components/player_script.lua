local coreFuncs = require("coreFuncs")
local weaponManager = require("desolation.weapon_manager")
local bulletScript = require("desolation.components.bullet_script")
local particleFuncs = require("desolation.particle_funcs")
local object = require("engine.object")
local itemEventFuncs = require("desolation.components.item.item_event_funcs")
local itemScript = require("desolation.components.item.item_script")
local moonshine = require("engine.lib.moonshine")

local playerScript = ENGINE_COMPONENTS.scriptComponent.new()

function playerScript:movement(delta, player)
    local speed = GetGlobal("p_speed")
    player.velocity = {0, 0}
    --Get input:
    if InputManager.inputType == "keyboard" then
        --KEYBOARD
        player.velocity[1] = coreFuncs.boolToNum(InputManager:isPressed("move_right")) - coreFuncs.boolToNum(InputManager:isPressed("move_left"))
        player.velocity[2] = coreFuncs.boolToNum(InputManager:isPressed("move_down")) - coreFuncs.boolToNum(InputManager:isPressed("move_up"))
    elseif InputManager.inputType == "joystick" then
        --JOYSTICK
        local axis1, axis2 = InputManager:getAxis(1), InputManager:getAxis(2)
        if math.abs(axis1) > 0.1 then
            player.velocity[1] = axis1
        end
        if math.abs(axis2) > 0.1 then
            player.velocity[2] = axis2
        end
    end
    player.moving = math.abs(player.velocity[1]) > 0 or math.abs(player.velocity[2]) > 0
    --Sprinting
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
    if player.sprinting then
        speed = speed * 1.6
    end
    --Normalize velocity
    if InputManager.inputType == "keyboard" and InputManager:isPressed({"move_left", "move_right"}) == InputManager:isPressed({"move_up", "move_down"}) and player.moving then
        player.velocity[1] = player.velocity[1] * math.sin(math.pi/4)
        player.velocity[2] = player.velocity[2] * math.sin(math.pi/4)
    end
    --Move by velocity
    player.oldPos = {player.position[1], player.position[2]}
    player.position[1] = player.position[1] + (player.velocity[1]*speed*delta)
    player.position[2] = player.position[2] + (player.velocity[2]*speed*delta)
end

function playerScript:collisionCheck(player, delta)
    if GetGlobal("noclip") > 0 then return end
    local size = {48, 48}
    local playerPos = {player.position[1]-size[1]/2, player.position[2]-size[2]/2}
    --iterate through walls
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if coreFuncs.aabbCollision(playerPos, wall.position, size, wallSize) then
            player.position = {player.oldPos[1], player.oldPos[2]}
        end
    end
    --iterate through props
    for _, prop in ipairs(CurrentScene.props.tree) do
        if prop.collidable then
            local src = prop.imageComponent.source
            local w, h = src:getWidth(), src:getHeight()
            local propSize = {prop.scale[1]*w, prop.scale[2]*h}
            local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
            if coreFuncs.aabbCollision(playerPos, propPos, size, propSize) then
                player.position = {player.oldPos[1], player.oldPos[2]}
                --pushing crates
                if prop.movable then
                    --calculate push rotation
                    local dx, dy = playerPos[1]-propPos[1], playerPos[2]-propPos[2]
                    local pushRot = math.atan2(dy, dx) + math.pi
                    local playerSpeed = GetGlobal("p_speed")
                    if player.sprinting then playerSpeed = playerSpeed*1.6 end
                    local vel = math.getVecValue(player.velocity)
                    prop.velocity[1] = prop.velocity[1] + vel*math.cos(pushRot)*playerSpeed/prop.mass/4
                    prop.velocity[2] = prop.velocity[2] + vel*math.sin(pushRot)*playerSpeed/prop.mass/4
                end
            end
        end
    end
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

function playerScript:doWalkingAnim(player)
    if not player.moving then return end
    local time = love.timer.getTime()
    local speed = 12
    if player.sprinting then speed = speed + 4 end
    player.animationSizeDiff = math.sin(time*speed)/5
    --Set image component values
    player.scale[1] = 4 + player.animationSizeDiff
    player.scale[2] = 4 + player.animationSizeDiff
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
    if (love.mouse.isDown(1) or InputManager:getAxis(6) > 0.4) and player.shootTimer > weapon.shootTime then
        player.shootTimer = 0
        --Check if there is ammo available in magazine
        if weapon.magAmmo < 1 then
            playerSounds:playStopSound(Assets.sounds["empty_mag"])
            return
        end
        if weapon.weaponType == "auto" then
            if player.reloading then return end
            --Fire weapon
            weapon.magAmmo = weapon.magAmmo - weapon.bulletPerShot
            playerSounds:playStopSound(Assets.sounds["shoot_" .. string.lower(weapon.name)])
            --Bullet instance creation
            local bullet = object.new(CurrentScene.bullets)
            bullet.position[1] = player.position[1] + math.cos(player.rotation)*weapon.bulletOffset
            bullet.position[2] = player.position[2] + math.sin(player.rotation)*weapon.bulletOffset
            bullet.rotation = player.rotation + math.uniform(-weapon.bulletSpread, weapon.bulletSpread)
            bullet:addComponent(table.new(bulletScript))
            bullet:addComponent(ENGINE_COMPONENTS.particleComponent.new(bullet))
            bullet.script:load()
            bullet.speed = weapon.bulletSpeed
            bullet.damage = weapon.bulletDamage
            CurrentScene.bullets:addChild(bullet)
        elseif weapon.ammoType == "shotgun" then
            player.reloading = false
            --Fire weapon
            weapon.magAmmo = weapon.magAmmo - 1
            playerSounds:playStopSound(Assets.sounds["shoot_" .. string.lower(weapon.name)])
            --Bullet instance creation
            local radians = math.pi*2 * (weapon.bulletSpread/360) --turn into radians
            for i = 1, weapon.bulletPerShot do
                local bullet = object.new(CurrentScene.bullets)
                bullet.position[1] = player.position[1] + math.cos(player.rotation)*weapon.bulletOffset
                bullet.position[2] = player.position[2] + math.sin(player.rotation)*weapon.bulletOffset
                bullet.rotation = player.rotation + (i-2)*(radians/weapon.bulletPerShot)
                bullet:addComponent(table.new(bulletScript))
                bullet:addComponent(ENGINE_COMPONENTS.particleComponent.new(bullet))
                bullet.script:load()
                bullet.speed = weapon.bulletSpeed
                bullet.damage = weapon.bulletDamage
                CurrentScene.bullets:addChild(bullet)
            end
        end
        --effects
        player.handOffset = -weapon.handRecoilIntensity
        if Settings.screen_shake and GetGlobal("freecam") < 1 then
            local camera = CurrentScene.camera
            local a = 1
            if math.random() < 0.5 then a = -1 end
            camera.position[1] = camera.position[1] + weapon.screenShakeIntensity*a
            a = 1
            if math.random() < 0.5 then a = -1 end
            camera.position[2] = camera.position[2] + weapon.screenShakeIntensity*a
        end
        --particles
        if Settings.weapon_flame_particles then
            local shootParticles = player.particleComponent
            particleFuncs.createShootParticles(shootParticles, player.rotation)
        end
        --hud stuff
        local hud = CurrentScene.hud.UIComponent
        hud.weaponImg.rotation = math.pi/8
        hud.weaponImg.scale = {-4, 4}
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
    local player = self.parent
    player.imageComponent.source = Assets.images.player_body
    player.scale = {4, 4}
    --Player variables
    player.velocity = {0, 0}
    player.health = 100 ; player.armor = 100
    player.armorAcquired = true
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
            revolver = 0;
            shotgun = 0;
        };
        slot = 1;
    }
    player.shootTimer = 0
    player.reloadTimer = 0
    player.oldPos = table.new(player.position)
    --TODO Find a better way to handle these key presses?
    player.keyPressData = {
        ["q"] = false;
        ["e"] = false;
    }
    --Starter weapon
    player.inventory.weapons[1] = weaponManager.Revolver.new()
    player.inventory.weapons[1].magAmmo = 6
    player.inventory.ammunition.light = 78
    player.inventory.weapons[2] = weaponManager.Shotgun.new()
    player.inventory.weapons[3] = weaponManager.AssaultRifle.new()

    RunConsoleCommand("cheats 1")
    player.health = 10
    player.armor = 15
end

function playerScript:update(delta)
    if GamePaused then return end

    local player = self.parent
    player.imageComponent.color = {Settings.brightness, Settings.brightness, Settings.brightness, 1}

    self:movement(delta, player)
    self:collisionCheck(player, delta)
    self:pointTowardsMouse(player)
    self:slotSwitching(player)
    self:doWalkingAnim(player)
    self:weaponDropping(player)
    self:shootingWeapon(delta, player)
    self:reloadingWeapon(delta, player)
    --Update hand offset
    player.handOffset = player.handOffset + (-player.handOffset) * 20 * delta
end

return playerScript