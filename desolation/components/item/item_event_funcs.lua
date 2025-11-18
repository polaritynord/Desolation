local itemEventFuncs = {}

function itemEventFuncs.createHUDNotif(source)
    --Notification in the HUD, creates the UI element (image) and adds it to the list where they're tracked.
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
	--Event for picking up a weapon.
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
    --continue the process if an empty slot exists, otherwise cancel the pickup process
	--(TODO: Make it switch between the current held weapon instead!)
    if emptySlot < 1 then return end
    --add self to player inventory
    item.gettingPickedUp = true
    weaponInv[emptySlot] = item.weaponData.new()
    --play sound
    SoundManager:restartSound(Assets.sounds["acquire"], Settings.vol_world)
end

function itemEventFuncs.ammoPickup(item)
    --Event for picking up ammo items.
	local player = CurrentScene.player
    local ammoType = string.sub(item.name, 6, #item.name) --"ammo_x", takes only the "x" part
    --TODO: move this to items.json.
    local amounts = {
        light = 13;
        medium = 30;
        shotgun = 6;
        revolver = 6;
    }
	--increment ammunition in player inventory
    player.inventory.ammunition[ammoType] = player.inventory.ammunition[ammoType] + amounts[ammoType]
    --play sound and create a HUD notification
    SoundManager:restartSound(Assets.sounds["acquire"], Settings.vol_world)
    itemEventFuncs.createHUDNotif("hud_acquire_" .. ammoType .. "_ammo")
    item.gettingPickedUp = true
end

function itemEventFuncs.medkitPickup(item)
	--Event for picking up medkits.
	--return if the player's health is full.
    local player = CurrentScene.player
    if player.health == 100 then return end
	--increase health by 25.
    player.health = player.health + 25
    if player.health > 100 then player.health = 100 end
    --play sound, HUD notification, and blue vignette effect
	SoundManager:restartSound(Assets.sounds["medkit_pickup"], Settings.vol_world)
    itemEventFuncs.createHUDNotif("hud_acquire_medkit")
    CurrentScene.gameShaders.script.blueOffset = 255
    item.gettingPickedUp = true
end

function itemEventFuncs.batteryPickup(item)
    --Event for picking up batteries (armor).
	local player = CurrentScene.player
	--return if player's armor is at full capacity
    if player.armor == 150 then return end
    --increase by 25
	player.armor = player.armor + 25
    if player.armor > 150 then player.armor = 150 end
    --play sound, HUD notification, and blue vignette effect
    SoundManager:restartSound(Assets.sounds["battery_pickup"], Settings.vol_world)
    itemEventFuncs.createHUDNotif("hud_acquire_battery")
    CurrentScene.gameShaders.script.blueOffset = 255
    item.gettingPickedUp = true
end

function itemEventFuncs.flashlightPickup(item)
    --Event for picking up a flashlight item. Of course, return if the player already has it.
	local player = CurrentScene.player
    if player.flashlightAcquired then return end
    player.flashlightAcquired = true
    --Play the "F for Flashlight" text in the UI
	local keyHintsScript = CurrentScene.keyHints.script
    keyHintsScript:addHintToQueue("f")
    --play sound
    SoundManager:restartSound(Assets.sounds["acquire"], Settings.vol_world)
    item.gettingPickedUp = true
end

return itemEventFuncs
