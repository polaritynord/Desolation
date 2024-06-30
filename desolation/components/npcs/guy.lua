local humanoidScript = require("desolation.components.humanoid_script")
local coreFuncs = require("coreFuncs")

local guyScript = table.new(humanoidScript)

function guyScript:pointTowardsPlayer(npc)
    local pos = npc.position
    local pos2 = CurrentScene.player.position
    local dx = pos2[1]-pos[1] ; local dy = pos2[2]-pos[2]
    npc.rotation = math.atan2(dy, dx)
end

function guyScript:neutralState(npc)
    self:pointTowardsPlayer(npc)
    --check player interaction
    local distance = coreFuncs.pointDistance(CurrentScene.player.position, npc.position)
    if distance > 160 then return end
    if not npc.interactPressed and InputManager:isPressed("interact") then
        npc.state = "follow"
    end
    npc.interactPressed = InputManager:isPressed("interact")
end

function guyScript:followState(npc)
    local player = CurrentScene.player
    self:pointTowardsPlayer(npc)
    --move towards player if distant enough
    local distance = coreFuncs.pointDistance(player.position, npc.position)
    npc.moveVelocity = {0, 0}
    if distance < 160 then return end
    local dx, dy = player.position[1]-npc.position[1], player.position[2]-npc.position[2]
    local angle = math.atan2(dy, dx)
    npc.moveVelocity[1] = 140 * math.cos(angle)
    npc.moveVelocity[2] = 140 * math.sin(angle)
end

function guyScript:load()
    local npc = self.parent
    self:humanoidSetup()
    npc.state = "neutral"
    npc.interactPressed = false
end

function guyScript:update(delta)
    local npc = self.parent
    self:humanoidUpdate(delta, npc)
    
    if npc.health <= 0 then return end
    --states
    if npc.state == "neutral" then
        self:neutralState(npc)
    elseif npc.state == "follow" then
        self:followState(npc)
    end
end

return guyScript