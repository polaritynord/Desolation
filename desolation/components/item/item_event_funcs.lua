local itemEventFuncs = {}

function itemEventFuncs.createHUDNotif(source)
    --notification in hud
    local hud = CurrentScene.hud.UIComponent
    local newNotif = hud:newImage(
        {
            position = {25, 420};
            source = Assets.images[source];
            color = {1, 1, 1, 0.7};
        }
    )
    newNotif.scale = {1.7, 1.7}
    newNotif.timer = 0
    hud.acquireNotifs[#hud.acquireNotifs+1] = newNotif
    newNotif.index = #hud.acquireNotifs
end

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
    playerSounds:playStopSound(Assets.sounds["acquire"])
end

function itemEventFuncs.ammoPickup(item)
    local player = CurrentScene.player
    local ammoType = string.sub(item.name, 6, #item.name)
    --TODO move this to items.json
    local amounts = {
        light = 13;
        medium = 30;
        shotgun = 6;
        revolver = 6;
    }
    player.inventory.ammunition[ammoType] = player.inventory.ammunition[ammoType] + amounts[ammoType]
    item.gettingPickedUp = true
    --play sound
    local playerSounds = player.soundManager.script
    playerSounds:playStopSound(Assets.sounds["acquire"])
    itemEventFuncs.createHUDNotif("hud_acquire_ammo")
end

function itemEventFuncs.medkitPickup(item)
    local player = CurrentScene.player
    if player.health == 100 then return end
    player.health = player.health + 25
    if player.health > 100 then player.health = 100 end
    --play sound (TODO: find a healing sound)
    local playerSounds = player.soundManager.script
    playerSounds:playStopSound(Assets.sounds["acquire"])
    --notification in hud
    itemEventFuncs.createHUDNotif("hud_acquire_medkit")
    --vignette effects & misc
    CurrentScene.gameShaders.script.blueOffset = 255
    item.gettingPickedUp = true
end

function itemEventFuncs.batteryPickup(item)
    local player = CurrentScene.player
    if player.armor == 100 then return end
    player.armor = player.armor + 25
    if player.armor > 100 then player.armor = 100 end
    --play sound (TODO: find a healing sound)
    local playerSounds = player.soundManager.script
    playerSounds:playStopSound(Assets.sounds["acquire"])
    --notification in hud
    itemEventFuncs.createHUDNotif("hud_acquire_battery")
    CurrentScene.gameShaders.script.blueOffset = 255
    item.gettingPickedUp = true
end

return itemEventFuncs