local playerHandScript = {}

function playerHandScript:load()
    local hand = self.parent
    hand.imageComponent.source = Assets.images.player.handDefault
end

function playerHandScript:update(delta)
end

return playerHandScript