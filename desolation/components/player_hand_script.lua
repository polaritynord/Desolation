local playerHandScript = ENGINE_COMPONENTS.scriptComponent.new()

function playerHandScript:load()
    local hand = self.parent
    hand.imageComponent.source = Assets.images.player.handDefault
    hand.imageComponent.layer = 2
end

function playerHandScript:update(delta)
    if GamePaused then return end
    
    local hand = self.parent
    local player = hand.parent
    --Set image for the hand
    local src = Assets.images.player.handDefault
    if player.inventory.weapons[player.inventory.slot] then
        src = Assets.images.player.handWeapon -- Placeholder.
    end
    hand.imageComponent.source = src
    --Move hands forward a bit
    local pos = table.new(player.position)
    pos[1] = pos[1] + math.cos(player.rotation) * (20 + player.handOffset)
    pos[2] = pos[2] + math.sin(player.rotation) * (20 + player.handOffset)
    --Set position
    hand.position = pos
    hand.rotation = player.rotation
    hand.scale = {
        2.8 + player.animationSizeDiff/2,
        2.8 + player.animationSizeDiff/2
    }
end

return playerHandScript