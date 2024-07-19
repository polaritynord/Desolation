local particleFuncs = require("desolation.particle_funcs")
local coreFuncs = require("coreFuncs")

local humanoidScript = ENGINE_COMPONENTS.scriptComponent.new()

function humanoidScript:collisionCheck(delta, humanoid)
    if humanoid.name == "player" and GetGlobal("noclip") > 0 then return end
    local size = {48, 48}
    local humanoidPos = {humanoid.position[1]-size[1]/2, humanoid.position[2]-size[2]/2}
    --iterate through walls
    for _, wall in ipairs(CurrentScene.walls.tree) do
        local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
        if coreFuncs.aabbCollision(humanoidPos, wall.position, size, wallSize) then
            humanoid.position = table.new(humanoid.oldPos)
        end
    end
    --iterate through props
    for _, prop in ipairs(CurrentScene.props.tree) do
        if prop.collidable then
            local src = prop.imageComponent.source
            local w, h = src:getWidth(), src:getHeight()
            local propSize = {prop.scale[1]*w, prop.scale[2]*h}
            local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
            if coreFuncs.aabbCollision(humanoidPos, propPos, size, propSize) then
                humanoid.position = table.new(humanoid.oldPos)
                if not humanoid.moving then
                    prop.velocity = {-prop.velocity[1], -prop.velocity[2]}
                end
                --pushing crates
                if prop.movable then
                    --calculate push rotation
                    local dx, dy = humanoidPos[1]-propPos[1], humanoidPos[2]-propPos[2]
                    local pushRot = math.atan2(dy, dx) + math.pi
                    local playerSpeed = 140 --NOTE speed??
                    if humanoid.sprinting then playerSpeed = playerSpeed*1.6 end
                    local vel =  math.getVecValue(humanoid.moveVelocity)/140
                    prop.velocity[1] = prop.velocity[1] + vel*math.cos(pushRot)*playerSpeed/prop.mass*delta*100
                    prop.velocity[2] = prop.velocity[2] + vel*math.sin(pushRot)*playerSpeed/prop.mass*delta*100
                end
            end
        end
    end
end

function humanoidScript:humanoidUpdate(delta, humanoid)
    --Update hand offset
    humanoid.handOffset = humanoid.handOffset + (-humanoid.handOffset) * 20 * delta
    --movement
    humanoid.moving = math.abs(humanoid.moveVelocity[1]) > 0 or math.abs(humanoid.moveVelocity[2]) > 0
    humanoid.oldPos = table.new(humanoid.position)
    humanoid.position[1] = humanoid.position[1] + (humanoid.velocity[1]*delta) + (humanoid.moveVelocity[1]*delta)
    humanoid.position[2] = humanoid.position[2] + (humanoid.velocity[2]*delta) + (humanoid.moveVelocity[2]*delta)
    humanoid.velocity[1] = humanoid.velocity[1] + (-humanoid.velocity[1])*8*delta
    humanoid.velocity[2] = humanoid.velocity[2] + (-humanoid.velocity[2])*8*delta
    self:collisionCheck(delta, humanoid)
    self:doWalkingAnim(humanoid)
    self:makeFootstepSounds(humanoid, delta)
    if humanoid.health > 0 then return end
    --fade away
    humanoid.scale[1] = humanoid.scale[1] + 20 * delta
    humanoid.scale[2] = humanoid.scale[2] + 20 * delta
    humanoid.imageComponent.color[4] = humanoid.imageComponent.color[4] - 25 * delta
    humanoid.hand.imageComponent.color[4] = humanoid.imageComponent.color[4]
    --remove from npc list
    if humanoid.imageComponent.color[4] > 0 or humanoid.name == "player" then return end
    table.removeValue(CurrentScene.npcs.tree, humanoid)
end

function humanoidScript:doWalkingAnim(humanoid)
    if not humanoid.moving then return end
    local time = love.timer.getTime()
    local speed = 12
    if humanoid.sprinting then speed = speed + 4 end
    humanoid.animationSizeDiff = math.sin(time*speed)/5
    --Set image component values
    humanoid.scale[1] = 4 + humanoid.animationSizeDiff
    humanoid.scale[2] = 4 + humanoid.animationSizeDiff
end

function humanoidScript:damage(amount, sourcePosition)
    local humanoid = self.parent
    if humanoid.name == "player" and GetGlobal("god") > 0 then return end
    --Reduce damage with armor
    if humanoid.armor > 0 then
        local armorReducePower = (humanoid.armor/70)*2
        if armorReducePower < 1 then armorReducePower = 1 end
        if armorReducePower > 2.5 then armorReducePower = 2.5 end
        amount = amount / armorReducePower
    end
    --Player events
    if humanoid.name == "player" then
        --play sound
        local src = Assets.sounds["hurt" .. math.random(1, 3)]
        SoundManager:restartSound(src, Settings.vol_world)
        --create hitmarker
        local uiComp = CurrentScene.hud.UIComponent
        local hitmarkerInstance = uiComp:newImage(
            {
                source = Assets.images["hud_hitmarker"];
                scale = {1, 2};
                color = {1, 0, 0, 1};
            }
        )
        local rotation = math.atan2(sourcePosition[2]-CurrentScene.camera.position[2], sourcePosition[1]-CurrentScene.camera.position[1]) + math.pi
        hitmarkerInstance.rotation = rotation
        hitmarkerInstance.position = {
            480-math.cos(rotation)*70,
            270-math.sin(rotation)*70
        }
        uiComp.hitmarkers[#uiComp.hitmarkers+1] = hitmarkerInstance
        --Screen shake
        if Settings.screen_shake and GetGlobal("freecam") < 1 then
            local camera = CurrentScene.camera
            local temp = {-1, 1}
            local max = 8.5
            camera.position[1] = camera.position[1] + temp[math.random(1,2)]*max
            camera.position[2] = camera.position[2] + temp[math.random(1,2)]*max
        end
    else
        --damageNumber UI
        CurrentScene.damageNumbers.numbers[#CurrentScene.damageNumbers.numbers+1] = {
            position = table.new(humanoid.position);
            alpha = 1;
            number = amount;
        }
    end
    --damage humanoid
    if humanoid.armor > amount then
        humanoid.armor = humanoid.armor - amount
        return
    elseif humanoid.armor > 0 then
        amount = amount - humanoid.armor
        humanoid.armor = 0
    end
    humanoid.health = humanoid.health - amount
end

function humanoidScript:explosionEvent(position, radius, intensity)
    local humanoid = self.parent
    local distance = coreFuncs.pointDistance(position, humanoid.position)
    if distance > radius then return end
    --add up velocity
    local dx, dy = humanoid.position[1]-position[1], humanoid.position[2]-position[2]
    local rot = math.atan2(dy, dx)
    humanoid.velocity[1] = humanoid.velocity[1] + math.cos(rot)*intensity*(radius/distance)*100
    humanoid.velocity[2] = humanoid.velocity[2] + math.sin(rot)*intensity*(radius/distance)*100
    --hurt player
    local damageAmount = 2*(radius/distance)*intensity
    self:damage(damageAmount, position)
end

function humanoidScript:hitscanBulletCheck(humanoid, weapon, shootAngle)
    local bulletPos = {
        humanoid.position[1] + math.cos(humanoid.rotation)*weapon.bulletOffset,
        humanoid.position[2] + math.sin(humanoid.rotation)*weapon.bulletOffset
    }
    local beginPos = table.new(bulletPos)
    local bulletSize = {12, 6}
    --(Infinite mode)
    if CurrentScene.shots ~= nil then
        CurrentScene.shots = CurrentScene.shots + 1
    end
    --Do the raycast thingy
    for i = 1, 40 do
        --*** check for collision ***
        --iterate through walls
        for _, wall in ipairs(CurrentScene.walls.tree) do
            local wallSize = {wall.scale[1]*64, wall.scale[2]*64}
            if coreFuncs.aabbCollision(bulletPos, wall.position, bulletSize, wallSize) then
                --create particles
                if Settings.destruction_particles then
                    local particleComp = CurrentScene.bullets.particleComponent
                    particleFuncs.createWallHitParticles(particleComp, bulletPos, shootAngle, i, wall.material)
                end
                goto returnLine
            end
        end
        --iterate through props
        for _, prop in ipairs(CurrentScene.props.tree) do
            if prop.collidable then
                local src = prop.imageComponent.source
                local w, h = src:getWidth(), src:getHeight()
                local propSize = {prop.scale[1]*w, prop.scale[2]*h}
                local propPos = {prop.position[1]-propSize[1]/2, prop.position[2]-propSize[2]/2}
                if coreFuncs.aabbCollision(bulletPos, propPos, bulletSize, propSize) then
                    --create particles
                    if Settings.destruction_particles then
                        local particleComp = CurrentScene.bullets.particleComponent
                        particleFuncs.createWallHitParticles(particleComp, bulletPos, shootAngle, i, prop.material)
                    end
                    --bullet hit event
                    if prop.script.physBulletHitEvent ~= nil then
                        prop.script:physBulletHitEvent(shootAngle, weapon)
                    end
                    goto returnLine
                end
            end
        end
        --iterate through NPC's
        for _, npc in ipairs(CurrentScene.npcs.tree) do
            if npc.name ~= humanoid.name then
                local src = npc.imageComponent.source
                local w, h = src:getWidth(), src:getHeight()
                local npcSize = {npc.scale[1]*w, npc.scale[2]*h}
                local propPos = {npc.position[1]-npcSize[1]/2, npc.position[2]-npcSize[2]/2}
                if coreFuncs.aabbCollision(bulletPos, propPos, bulletSize, npcSize) then
                    --damage npc
                    npc.script:damage(weapon.bulletDamage)
                    if npc.script.bulletHitEvent ~= nil then npc.script:bulletHitEvent(humanoid) end
                    --TODO: bullet hit sfx or an indicator?
                    goto returnLine
                end
            end
        end
        --check player collision
        if humanoid.name ~= "player" then
            local player = CurrentScene.player
            local src = player.imageComponent.source
            local w, h = src:getWidth(), src:getHeight()
            local npcSize = {player.scale[1]*w, player.scale[2]*h}
            local propPos = {player.position[1]-npcSize[1]/2, player.position[2]-npcSize[2]/2}
            if coreFuncs.aabbCollision(bulletPos, propPos, bulletSize, npcSize) then
                --damage npc
                player.script:damage(weapon.bulletDamage, beginPos)
                if player.script.bulletHitEvent ~= nil then player.script:bulletHitEvent(bullet) end
                goto returnLine
            end
        end
        --move bullet by 25 pixels
        bulletPos[1] = bulletPos[1] + 25*math.cos(shootAngle)
        bulletPos[2] = bulletPos[2] + 25*math.sin(shootAngle)
    end
    --If the function is still ongoing at this part, that means the bullet is out of range.
    --(Infinite mode)
    if CurrentScene.shotsMissed ~= nil then
        CurrentScene.shotsMissed = CurrentScene.shotsMissed + 1
    end
    ::returnLine::
    return {beginPos, bulletPos, weapon.fireLineWidth, {weapon.fireLineColor[1], weapon.fireLineColor[2], weapon.fireLineColor[3], math.uniform(0.6, 0.8)}}
    --LINE TABLE ORDER: begin position, ending position, line width, color
end

function humanoidScript:humanoidShootWeapon(weapon)
    local humanoid = self.parent
    if weapon == nil or humanoid.shootTimer < weapon.shootTime then return end

    humanoid.shootTimer = 0
    --Check if there is ammo available in magazine
    if weapon.magAmmo < 1 and not humanoid.reloading then
        SoundManager:restartSound(Assets.sounds["empty_mag"], Settings.vol_world, humanoid.position, true)
        return
    end
    local shootSound = Assets.sounds["shoot_" .. string.lower(weapon.name)]
    if weapon.weaponType == "auto" or weapon.weaponType == "laser" then
        if humanoid.reloading then return end
        --Fire weapon
        weapon.magAmmo = weapon.magAmmo - weapon.bulletPerShot
        --Sound effect
        if shootSound ~= nil then
            SoundManager:restartSound(shootSound, Settings.vol_world, humanoid.position, true)
        end
        local newLine = self:hitscanBulletCheck(
            humanoid, weapon, humanoid.rotation + math.uniform(-weapon.bulletSpread, weapon.bulletSpread)
        )
        CurrentScene.bulletLineRenderer.lines[#CurrentScene.bulletLineRenderer.lines+1] = newLine
        --[[Bullet instance creation
        local bullet = object.new(CurrentScene.bullets)
        bullet.owner = humanoid.name
        bullet.position[1] = humanoid.position[1] + math.cos(humanoid.rotation)*weapon.bulletOffset
        bullet.position[2] = humanoid.position[2] + math.sin(humanoid.rotation)*weapon.bulletOffset
        bullet.rotation = humanoid.rotation + math.uniform(-weapon.bulletSpread, weapon.bulletSpread)
        bullet:addComponent(table.new(bulletScript))
        bullet.script:load()
        bullet.speed = weapon.bulletSpeed
        bullet.damage = weapon.bulletDamage
        CurrentScene.bullets:addChild(bullet)
        --]]
    elseif weapon.ammoType == "shotgun" then
        if weapon.magAmmo < 1 then return end
        humanoid.reloading = false
        --Fire weapon
        weapon.magAmmo = weapon.magAmmo - 1
        if shootSound ~= nil then
            SoundManager:restartSound(shootSound, Settings.vol_world, humanoid.position, true)
        end
        --Bullet instance creation
        local radians = math.pi*2 * (weapon.bulletSpread/360) --turn into radians
        for i = 1, weapon.bulletPerShot do
            --[[
            local bullet = object.new(CurrentScene.bullets)
            bullet.owner = humanoid.name
            bullet.position[1] = humanoid.position[1] + math.cos(humanoid.rotation)*weapon.bulletOffset
            bullet.position[2] = humanoid.position[2] + math.sin(humanoid.rotation)*weapon.bulletOffset
            bullet.rotation = humanoid.rotation + (i-2)*(radians/weapon.bulletPerShot)
            bullet:addComponent(table.new(bulletScript))
            bullet.script:load()
            bullet.speed = weapon.bulletSpeed
            bullet.damage = weapon.bulletDamage
            CurrentScene.bullets:addChild(bullet)
            ]]--
            local newLine = self:hitscanBulletCheck(
                humanoid, weapon, humanoid.rotation + (i-2)*(radians/weapon.bulletPerShot)
            )
            CurrentScene.bulletLineRenderer.lines[#CurrentScene.bulletLineRenderer.lines+1] = newLine
        end
    end
    --weapon flame particles
    local shootParticles = CurrentScene.bullets.particleComponent
    if Settings.weapon_flame_particles then
        particleFuncs.createShootParticles(humanoid, shootParticles, humanoid.rotation)
    end
    --bullet shell particles
    particleFuncs.createBulletShellParticle(shootParticles, humanoid, weapon)
    
    --***player stuff down here***
    if humanoid.name ~= "player" then return end
    humanoid.handOffset = -weapon.handRecoilIntensity
    if Settings.screen_shake and GetGlobal("freecam") < 1 then
        local camera = CurrentScene.camera
        local a = 1
        if math.random() < 0.5 then a = -1 end
        camera.position[1] = camera.position[1] + weapon.screenShakeIntensity*a
        a = 1
        if math.random() < 0.5 then a = -1 end
        camera.position[2] = camera.position[2] + weapon.screenShakeIntensity*a
    end
    --hud stuff
    local hud = CurrentScene.hud.UIComponent
    hud.weaponImg.rotation = math.pi/8
    hud.weaponImg.scale = {-4, 4}
end

function humanoidScript:makeFootstepSounds(humanoid, delta)
    --footstep sounds
    if humanoid.moving then
        self.stepTimer = self.stepTimer + delta
        if self.stepTimer > 0.4 - coreFuncs.boolToNum(humanoid.sprinting)*0.15 then
            SoundManager:restartSound(Assets.mapSounds["step_grass" .. math.random(1, 4)], Settings.vol_world, humanoid.position, true)
            self.stepTimer = 0
        end
    else
        self.stepTimer = 0
    end
end

function humanoidScript:humanoidSetup()
    local humanoid = self.parent
    humanoid.imageComponent.source = Assets.images["player_body"]
    humanoid.velocity = {0, 0}
    humanoid.moveVelocity = {0, 0}
    humanoid.health = 100
    humanoid.armor = 0
    humanoid.stamina = 100
    humanoid.scale = {4, 4}
    humanoid.reloading = false
    humanoid.moving = false
    humanoid.sprinting = false
    humanoid.inventory = {
        weapons = {nil, nil, nil};
        items = {};
        grenades = 3;
        ammunition = {
            light = 0;
            medium = 0;
            revolver = 0;
            shotgun = 0;
        };
        slot = 1;
    }
    humanoid.shootTimer = 0
    humanoid.reloadTimer = 0
    humanoid.oldPos = table.new(humanoid.position)
    humanoid.animationSizeDiff = 0
    humanoid.handOffset = 0
    humanoid.unarmed = false
end

return humanoidScript