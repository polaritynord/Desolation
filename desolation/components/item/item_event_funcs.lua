local itemEventFuncs = {}

function itemEventFuncs.weaponPickup(item)
    local player = CurrentScene.player
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
    --add self to player inventory
    item.gettingPickedUp = true
    weaponInv[emptySlot] = item.weaponData.new()
    --play sound
    local playerSounds = player.soundManager.script
    playerSounds:playStopSound(playerSounds.sounds.acquire)
end

function itemEventFuncs.ammoPickup(item)
    local player = CurrentScene.player
    local ammoType = string.sub(item.name, 6, #item.name)
    player.inventory.ammunition[ammoType] = player.inventory.ammunition[ammoType] + 20
    item.gettingPickedUp = true
    --play sound
    local playerSounds = player.soundManager.script
    playerSounds:playStopSound(playerSounds.sounds.acquire)
end

return itemEventFuncs