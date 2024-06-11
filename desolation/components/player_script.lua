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
    local slippiness = GetGlobal("slippiness")

    player.velocity[1] = player.velocity[1] + (-player.velocity[1])*slippiness*delta
    player.velocity[2] = player.velocity[2] + (-player.velocity[2])*slippiness*delta
    --Get key input
    if InputManager:isPressed("move_left") then
        player.velocity[1] = -1
    end
    if InputManager:isPressed("move_right") then
        player.velocity[1] = 1
    end
    if InputManager:isPressed("move_up") then
        player.velocity[2] = -1
    end
    if InputManager:isPressed("move_down") then
        player.velocity[2] = 1
    end
    player.moving = InputManager:isPressed({"move_left", "move_right", "move_up", "move_down"})
    --Sprinting
    player.sprinting = (InputManager:isPressed("sprint") and not Settings.always_sprint) or (player.moving and Settings.always_sprint and not InputManager:isPressed("sprint"))
    if player.sprinting then
        speed = speed * 1.6
    end
    --Normalize velocity
    if InputManager:isPressed({"move_left", "move_right"}) == InputManager:isPressed({"move_up", "move_down"}) and player.moving then
        player.velocity[1] = player.velocity[1] * math.sin(math.pi/4)
        player.velocity[2] = player.velocity[2] * math.sin(math.pi/4)
    end
    --Move by velocity
    player.position[1] = player.position[1] + (player.velocity[1]*speed*delta)
    player.position[2] = player.position[2] + (player.velocity[2]*speed*delta)
end

function playerScript:collisionCheck(player)
    if true then return end
    --iterate through walls
    local w, h = 48, 48
    local playerPos = {player.position[1]-24, player.position[2]-24}
    player.imageComponent.color = {1, 1, 1, 1}
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if playerPos[1] < wall.position[1]+wallSize[1] and playerPos[1]+w < wall.position[1] and
            playerPos[2] < wall.position[2]+wallSize[2] and playerPos[2]+h < wall.position[2] then
            player.imageComponent.color = {0, 1, 0, 1}
        end
    end
end

function playerScript:pointTowardsMouse(player)
    local mouseX, mouseY = coreFuncs.getRelativeMousePosition()
    local pos = coreFuncs.getRelativePosition(player.position, CurrentScene.camera)
    local dx = mouseX-pos[1] ; local dy = mouseY-pos[2]
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
        if weapon then
            local playerSounds = player.soundManager.script
            playerSounds:stopSound(playerSounds.sounds.reload[weapon.name])
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
    itemInstance.imageComponent.source = Assets.images.weapons[string.lower(weapon.name) .. "Img"]
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
        if playerSounds.sounds.reload[weapon.name] then
            playerSounds:stopSound(playerSounds.sounds.reload[weapon.name])
        end
    end
    --Get rid of the held weapon
    player.inventory.weapons[player.inventory.slot] = nil
    --play sound
    local playerSounds = player.soundManager.script
    playerSounds:playStopSound(playerSounds.sounds.drop)
end

function playerScript:shootingWeapon(delta, player)
    player.shootTimer = player.shootTimer + delta
    local weapon = player.inventory.weapons[player.inventory.slot]
    if not weapon or player.reloading then return end
    local playerSounds = player.soundManager.script
    if love.mouse.isDown(1) and player.shootTimer > weapon.shootTime then
        player.shootTimer = 0
        --Check if there is ammo available in magazine
        if weapon.magAmmo < 1 then
            playerSounds:stopSound(playerSounds.sounds.shoot.empty)
            return
        end
        --Fire weapon
        weapon.magAmmo = weapon.magAmmo - weapon.bulletPerShot
        playerSounds:playStopSound(playerSounds.sounds.shoot[weapon.name])
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
        --Bullet instance creation
        local bullet = object.new(CurrentScene.bullets)
        bullet.position[1] = player.position[1] + math.cos(player.rotation)*weapon.bulletOffset
        bullet.position[2] = player.position[2] + math.sin(player.rotation)*weapon.bulletOffset
        bullet.rotation = player.rotation
        bullet:addComponent(table.new(bulletScript))
        --bullet.script = table.new(bulletScript)
        --bullet.script.parent = bullet
        bullet.script:load()
        CurrentScene.bullets:addChild(bullet)
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
        end
    else
        if InputManager:isPressed("reload") then
            local playerSounds = player.soundManager.script
            playerSounds:playStopSound(playerSounds.sounds.reload[weapon.name])
            player.reloading = true
            player.reloadTimer = 0
        end
    end
end

--Engine funcs
function playerScript:load()
    local player = self.parent
    player.imageComponent.source = Assets.images.player.body
    player.scale = {4, 4}
    --Player variables
    player.velocity = {0, 0}
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
    player.inventory.weapons[1] = weaponManager.Pistol.new()
    player.inventory.weapons[1].magAmmo = 7
    player.inventory.ammunition.light = 78
    player.inventory.weapons[2] = weaponManager.Shotgun.new()
    player.inventory.weapons[3] = weaponManager.AssaultRifle.new()

    RunConsoleCommand("cheats 1")
    player.health = 40
end

function playerScript:update(delta)
    if GamePaused then return end

    local player = self.parent
    player.imageComponent.color = {Settings.brightness, Settings.brightness, Settings.brightness, 1}

    self:movement(delta, player)
    self:collisionCheck(player)
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