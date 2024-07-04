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
    robot.inventory.weapons[1] = weaponManager.Shotgun.new()
    robot.inventory.weapons[1].magAmmo = 100
end

function robotScript:update(delta)
    if GamePaused then return end
    local robot = self.parent
    self:humanoidUpdate(delta, robot)

    if robot.health <= 0 then return end
    --point & shoot at player
    self:pointTowardsPlayer(robot)
    robot.shootTimer = robot.shootTimer + delta/3
    local distance = coreFuncs.pointDistance(robot.position, CurrentScene.player.position)
    if distance > 500 then return end
    self:humanoidShootWeapon(robot.inventory.weapons[robot.inventory.slot])
end

return robotScript