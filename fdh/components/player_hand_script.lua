local playerHandScript = {}

function playerHandScript:load()
    local hand = self.parent
    hand.imageComponent.source = Assets.images.player.handDefault
end

function playerHandScript:update(delta)
    local hand = self.parent
    local player = hand.parent
    --Set image for the hand
    local src = Assets.images.player.handDefault
    if player.inventory.weapons[player.inventory.slot] then
        src = Assets.images.player.handWeapon -- Placeholder.
    end
    hand.imageComponent.source = src
    --Move hands forward a bit
    local pos = player:getPosition()
    pos.x = pos.x + math.cos(player.transformComponent.rotation) * (20 + player.handOffset)
    pos.y = pos.y + math.sin(player.transformComponent.rotation) * (20 + player.handOffset)
    --Set position
    hand.transformComponent.x = pos.x
    hand.transformComponent.y = pos.y
    hand.transformComponent.rotation = player.transformComponent.rotation
    hand.transformComponent.scale = {
        x=2.8 + player.animationSizeDiff/2,
        y=2.8 + player.animationSizeDiff/2
    }
end

return playerHandScript