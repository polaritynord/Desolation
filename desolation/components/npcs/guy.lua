local humanoidScript = require("desolation.components.humanoid_script")
local coreFuncs = require("coreFuncs")
local weaponManager = require("desolation.weapon_manager")

local guyScript = table.new(humanoidScript)

function guyScript:pointTowardsPlayer(npc)
    local pos = npc.position
    local pos2 = CurrentScene.player.position
    local dx = pos2[1]-pos[1] ; local dy = pos2[2]-pos[2]
    npc.rotation = math.atan2(dy, dx)
end

function guyScript:bulletHitEvent(humanoid)
    if humanoid.name ~= "player" then return end
    self.parent.state = "hostile_player"
end

function guyScript:neutralState(npc)
    self:pointTowardsPlayer(npc)
    npc.unarmed = true
    --check player interaction
    local distance = coreFuncs.pointDistance(CurrentScene.player.position, npc.position)
    if distance > 160 then return end
    if not npc.interactPressed and InputManager:isPressed("toggle_follow") then
        npc.state = "follow"
        --add following marker to HUD
        local uiComp = CurrentScene.hud.UIComponent
        local img = uiComp:newImage(
            {
                source =  Assets.images["hud_hitmarker"];
                scale = {1.2, 1.2};
                rotation = -math.pi/2;
                position = {
                    (npc.position[1]-CurrentScene.camera.position[1])*CurrentScene.camera.zoom+480,
                    (npc.position[2]-CurrentScene.camera.position[2]-50)*CurrentScene.camera.zoom+270
                }
            }
        )
        img.parentHumanoid = npc
        img.parentIndex = table.contains(CurrentScene.npcs.tree, npc, true)
        uiComp.followingImgs[#uiComp.followingImgs+1] = img
    end
end

function guyScript:followState(npc)
    local player = CurrentScene.player
    self:pointTowardsPlayer(npc)
    npc.unarmed = true
    --check player interaction
    if not npc.interactPressed and InputManager:isPressed("toggle_follow") then
        npc.state = "neutral"
        return
    end
    --move towards player if distant enough
    local distance = coreFuncs.pointDistance(player.position, npc.position)
    if distance < 160 then return end
    local dx, dy = player.position[1]-npc.position[1], player.position[2]-npc.position[2]
    local angle = math.atan2(dy, dx)
    npc.moveVelocity[1] = 140 * math.cos(angle)
    npc.moveVelocity[2] = 140 * math.sin(angle)
end

function guyScript:hostilePlayerState(npc, delta)
    npc.shootTimer = npc.shootTimer + delta
    npc.unarmed = false
    self:pointTowardsPlayer(npc)
    self:humanoidShootWeapon(npc.inventory.weapons[npc.inventory.slot])
end

function guyScript:load()
    local npc = self.parent
    self:humanoidSetup()
    npc.state = "neutral"
    npc.interactPressed = false
    npc.inventory.weapons[1] = weaponManager.Pistol:new()
    npc.inventory.weapons[1].magAmmo = 13
end

function guyScript:update(delta)
    if GamePaused then return end
    local npc = self.parent
    self:humanoidUpdate(delta, npc)

    if npc.health <= 0 then return end
    npc.moveVelocity = {0, 0}
    --states
    if CurrentScene.player == nil then return end
    if npc.state == "neutral" then
        self:neutralState(npc)
    elseif npc.state == "follow" then
        self:followState(npc)
    elseif npc.state == "hostile_player" then
        self:hostilePlayerState(npc, delta)
    end
    npc.interactPressed = InputManager:isPressed("toggle_follow")
end

return guyScript