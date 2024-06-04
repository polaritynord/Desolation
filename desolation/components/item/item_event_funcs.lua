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
    self.gettingPickedUp = true
    --add self to player inventory
    weaponInv[emptySlot] = item.weaponData.new()
end

return itemEventFuncs