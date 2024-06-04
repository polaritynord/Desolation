local coreFuncs = require("coreFuncs")

local weaponItem = ENGINE_COMPONENTS.scriptComponent.new()

function weaponItem:movement(delta, item)
    local itemPos = item.position
    local playerPos = CurrentScene.player.position
    if self.gettingPickedUp then
        itemPos[1] = itemPos[1] + (playerPos[1]-itemPos[1])*10*delta
        itemPos[2] = itemPos[2] + (playerPos[2]-itemPos[2])*10*delta
        --Set alpha
        item.imageComponent.color[4] = self.distanceToPlayer/100
    else
        --Move
        itemPos[1] = itemPos[1] + self.velocity*math.cos(self.realRot)*delta
        itemPos[2] = itemPos[2] + self.velocity*math.sin(self.realRot)*delta
        --Slow down
        self.velocity = self.velocity - 2000*delta
        if self.velocity < 0 then self.velocity = 0 end
        --Turn & velocity decrease
        item.rotation = item.rotation - self.rotVelocity*delta
        self.rotVelocity = self.rotVelocity + (-self.rotVelocity)*math.pi*2*delta
    end
    --Set new position
    --item.transformComponent.x = itemPos[1]
    --item.transformComponent.y = itemPos[2]
end

function weaponItem:load()
    local item = self.parent
    self.parent.imageComponent = ENGINE_COMPONENTS.imageComponent.new(
        item,
        Assets.images.weapons[string.lower(item.weaponData.name) .. "Img"]
    )
    --Component setup
    item.imageComponent.layer = 2
    item.scale = {2, 2}
    --Some vars
    self.gettingPickedUp = false
    self.distanceToPlayer = 1000
end

function weaponItem:update(delta)
    if GamePaused then return end
    --Remove self if getting picked up is complete
    if self.distanceToPlayer < 10 and self.gettingPickedUp then
        table.removeValue(CurrentScene.items.tree, self.parent)
        return
    end

    local item = self.parent
    local player = CurrentScene.player

    self:movement(delta, item)
    --Distance calculation
    self.distanceToPlayer = coreFuncs.pointDistance(item.position, player.position)
    --set sum colors & return if player is far away
    --TODO better indicator
    if self.distanceToPlayer > 100 then
        item.imageComponent.color = {1, 1, 1, 1}
        return
    end
    item.imageComponent.color = {1, 0, 0, 1}
    --Picking up
    if InputManager:isPressed("interact") and not player.keyPressData["e"] and not self.gettingPickedUp then
        --check if player has an empty slot (TODO: optimize)
        local weaponInv = player.inventory.weapons
        local emptySlot = 0
        if weaponInv[player.inventory.slot] == nil then
            emptySlot = player.inventory.slot
        else
            for i = 1, 3 do
                if weaponInv[i] == nil then emptySlot = i; break end
            end
        end
        --continue the process if an empty slot exists
        if emptySlot < 1 then return end
        self.gettingPickedUp = true
        --add self to player inventory
        weaponInv[emptySlot] = item.weaponData.new()
        --play sound effect
        local playerSounds = player.soundManager.script
        love.audio.stop(playerSounds.sounds.acquire)
        love.audio.play(playerSounds.sounds.acquire)
    end
end

return weaponItem