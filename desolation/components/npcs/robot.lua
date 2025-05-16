local humanoidScript = require("desolation.components.humanoid_script")
local weaponManager = require("desolation.weapon_manager")
local coreFuncs = require("coreFuncs")

local robotScript = table.new(humanoidScript)

function robotScript:pointTowardsPlayer(robot)
    local pos = robot.position
    local pos2 = CurrentScene.player.position
    local dx = pos2[1]-pos[1] ; local dy = pos2[2]-pos[2]
    robot.rotation = math.atan2(dy, dx)
end

function robotScript:load()
    local robot = self.parent
    self:humanoidSetup()
    robot.imageComponent.color = {0.4, 0.4, 0.4, 1}
    robot.hand.imageComponent.color = robot.imageComponent.color
    --Determine weapon
    local name = "Pistol"
    local wave = CurrentScene.wave
    if wave > 6 then
        local c = math.random()
        if c < 0.35 then
            name = "AssaultRifle"
        elseif c < 0.85 then
            name = "Shotgun"
        end
    elseif wave > 3 then
        local c = math.random()
        if c < 0.45 then
            name = "AssaultRifle"
        end
    end
    local weapon = weaponManager[name].new()
    weapon.magAmmo = 100
    weapon.bulletDamage = weapon.bulletDamage * (CurrentScene.difficulty+1)/5
    robot.inventory.weapons[1] = weapon
    robot.health = 50 * (CurrentScene.difficulty+1)/4
    robot.lootDropped = false
end

function robotScript:update(delta)
    if GamePaused then return end
    local robot = self.parent
    self:humanoidUpdate(delta, robot)

    if robot.health <= 0 then
        --***Drop loot***
        if not robot.lootDropped then
            local itemData = {
                "ammo_light", table.new(robot.position), math.uniform(0, 360)
            }
            --Determine item type
            local n = math.random()
            if n <= 0.35 then
                itemData[1] = coreFuncs.infiniteModeAmmoType(CurrentScene.wave)
            else
                n = math.random()
                if n <= 0.4 then
                    itemData[1] = "medkit"
                else
                    itemData[1] = "battery"
                end
            end
            --if n < 0.25 then
            --    itemData[1] = "ammo_medium"
            --elseif n >= 0.25 and n < 0.45 then
            --    itemData[1] = "ammo_shotgun"
            --elseif n >= 0.45 and n < 0.57 then
            --    itemData[1] = "medkit"
            --elseif n >= 0.57 and n < 0.7 then
            --    itemData[1] = "battery"
            --end
			
            local item = CurrentScene.mapCreator.script:spawnItem(itemData)
            item.velocity = math.uniform(250, 400)
            --score
            if CurrentScene.score ~= nil then
                CurrentScene.hud.scoreNotifs.script:newNotif(Loca.infiniteMode.notifs.kill)
                CurrentScene.score = CurrentScene.score + 10
                CurrentScene.kills = CurrentScene.kills + 1
            end
        end
        robot.lootDropped = true
        --***Give Score***
        return
    end
    self:pointTowardsPlayer(robot)
    robot.shootTimer = robot.shootTimer + delta/3
    local distance = coreFuncs.pointDistance(robot.position, CurrentScene.player.position)
    if distance > 500 then
        --walk towards player
        local dx, dy = CurrentScene.player.position[1]-robot.position[1], CurrentScene.player.position[2]-robot.position[2]
        local angle = math.atan2(dy, dx)
        robot.moveVelocity[1] = 140 * math.cos(angle)
        robot.moveVelocity[2] = 140 * math.sin(angle)
    else
        robot.moveVelocity = {0, 0}
    end
    if distance < 620 and CurrentScene.player.health > 0 then
        local weapon = robot.inventory.weapons[robot.inventory.slot]
        self:humanoidShootWeapon(weapon)
    end
end

return robotScript