local weaponItem = {}

function weaponItem:movement(delta, item)
    local itemPos = item:getPosition()
    local playerPos = CurrentScene.player:getPosition()
    if self.gettingPickedUp then
        itemPos.x = itemPos.x + (playerPos.x-itemPos.x)*10*delta
        itemPos.y = itemPos.y + (playerPos.y-itemPos.y)*10*delta
        --Set alpha
        item.imageComponent.color[4] = self.distanceToPlayer/100
    else
        --Move
        itemPos.x = itemPos.x + self.velocity*math.cos(self.realRot)*delta
        itemPos.y = itemPos.y + self.velocity*math.sin(self.realRot)*delta
        --Slow down
        self.velocity = self.velocity - 2000*delta
        if self.velocity < 0 then self.velocity = 0 end
        --Turn & velocity decrease
        item.transformComponent.rotation = item.transformComponent.rotation - self.rotVelocity*delta
        self.rotVelocity = self.rotVelocity + (-self.rotVelocity)*math.pi*2*delta
    end
    --Set new position
    item.transformComponent.x = itemPos.x
    item.transformComponent.y = itemPos.y
end

function weaponItem:load()
    local item = self.parent
    self.parent.imageComponent = ENGINE_COMPONENTS.imageComponent.new(
        item,
        Assets.images.weapons[string.lower(item.weaponData.name) .. "Img"]
    )
    --Component setup
    item.imageComponent.layer = 2
    item.transformComponent.scale = {x=2, y=2}
    --Some vars
    self.gettingPickedUp = false
    self.distanceToPlayer = 1000
end

function weaponItem:update(delta)
    --Remove self if getting picked up is complete
    if self.distanceToPlayer < 10 and self.gettingPickedUp then
        table.removeValue(CurrentScene.items.tree, self.parent)
        return
    end

    local item = self.parent
    local player = CurrentScene.player

    self:movement(delta, item)
    --Distance calculation
    local itemPos = item:getPosition()
    local playerPos = player:getPosition()
    self.distanceToPlayer = math.sqrt(
        (itemPos.x-playerPos.x)*(itemPos.x-playerPos.x)
        + (itemPos.y-playerPos.y)*(itemPos.y-playerPos.y)
    )
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
    end
end

return weaponItem