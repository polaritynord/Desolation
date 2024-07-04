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
    robot.inventory.weapons[1] = weaponManager.Pistol.new()
    robot.inventory.weapons[1].magAmmo = 100
    robot.health = 40
end

function robotScript:update(delta)
    if GamePaused then return end
    local robot = self.parent
    self:humanoidUpdate(delta, robot)

    if robot.health <= 0 then return end
    self:pointTowardsPlayer(robot)
    robot.shootTimer = robot.shootTimer + delta/3
    local distance = coreFuncs.pointDistance(robot.position, CurrentScene.player.position)
    if distance > 500 then
        --walk towards player
        local dx, dy = CurrentScene.player.position[1]-robot.position[1], CurrentScene.player.position[2]-robot.position[2]
        local angle = math.atan2(dy, dx)
        robot.moveVelocity[1] = 140 * math.cos(angle)
        robot.moveVelocity[2] = 140 * math.sin(angle)
    end
    if distance < 620 then
        self:humanoidShootWeapon(robot.inventory.weapons[robot.inventory.slot])
    end
end

return robotScript