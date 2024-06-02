local imageComponent = require("engine.components.image_component")

local bulletScript = {}

function bulletScript:load()
    local bullet = self.parent
    bullet.imageComponent = imageComponent.new(bullet, Assets.images.bullet)
    bullet.imageComponent.layer = 2
    bullet.timer = 0
    bullet.lifetime = 1
end

function bulletScript:update(delta)
    local bullet = self.parent
    bullet.timer = bullet.timer + delta
    --Check for despawn
    if bullet.timer > bullet.lifetime then
        table.removeValue(CurrentScene.bullets.tree, bullet)
        return
    end
    --Movement
    bullet.position[1] = bullet.position[1] + math.cos(bullet.rotation)*3000*delta
    bullet.position[2] = bullet.position[2] + math.sin(bullet.rotation)*3000*delta
end

return bulletScript