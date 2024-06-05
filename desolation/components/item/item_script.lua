local coreFuncs = require("coreFuncs")

local itemScript = ENGINE_COMPONENTS.scriptComponent.new()

function itemScript:load()
    local item = self.parent
    item:addComponent(ENGINE_COMPONENTS.imageComponent.new(item))
    --other
    if item.name == "weapon" then
        item.scale = {2, 2}
    elseif string.sub(item.name, 1, 5) == "ammo_" then
        item.scale = {0.35, 0.35}
    end

    item.distanceToPlayer = 1000
    item.gettingPickedUp = false
    item.velocity = 0
    item.rotVelocity = 0
    item.realRot = 0
end

function itemScript:movement(delta)
    local item = self.parent
    local playerPos = CurrentScene.player.position
    local itemPos = item.position
    if item.gettingPickedUp then
        itemPos[1] = itemPos[1] + (playerPos[1]-itemPos[1])*10*delta
        itemPos[2] = itemPos[2] + (playerPos[2]-itemPos[2])*10*delta
        --Set alpha
        item.imageComponent.color[4] = item.distanceToPlayer/100
    else
        --Move
        itemPos[1] = itemPos[1] + item.velocity*math.cos(item.realRot)*delta
        itemPos[2] = itemPos[2] + item.velocity*math.sin(item.realRot)*delta
        --Slow down
        item.velocity = item.velocity - 2000*delta
        if item.velocity < 0 then item.velocity = 0 end
        --Turn & velocity decrease
        item.rotation = item.rotation - item.rotVelocity*delta
        item.rotVelocity = item.rotVelocity + (-item.rotVelocity)*math.pi*2*delta
    end
end

function itemScript:update(delta)
    if GamePaused then return end
    local item = self.parent
    --Remove self if getting picked up is complete
    if item.distanceToPlayer < 10 and item.gettingPickedUp then
        table.removeValue(CurrentScene.items.tree, item)
        return
    end

    local player = CurrentScene.player
    self:movement(delta)
    --Distance calculation
    item.distanceToPlayer = coreFuncs.pointDistance(item.position, player.position)
    --set sum colors & return if player is far away
    --TODO better indicator
    if item.distanceToPlayer > 100 then
        item.imageComponent.color = {Settings.brightness, Settings.brightness, Settings.brightness, 1}
        return
    end
    item.imageComponent.color = {Settings.brightness, 0, 0, 1}
    --Picking up
    if InputManager:isPressed("interact") and not player.keyPressData["e"] and not item.gettingPickedUp then
        if item.pickupEvent ~= nil then
            item.pickupEvent(item)
            item.gettingPickedUp = true
        end
        --play sound effect
        local playerSounds = player.soundManager.script
        playerSounds:playStopSound(playerSounds.sounds.acquire)
    end
end

return itemScript