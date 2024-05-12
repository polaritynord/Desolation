local playerScript = {}

function playerScript:load()
    local player = self.parent
    player.imageComponent.source = Assets.images.player.body
end

function playerScript:update() end

return playerScript