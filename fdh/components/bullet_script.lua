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
    local pos = bullet:getPosition()
    pos.x = pos.x + math.cos(bullet.transformComponent.rotation)*3000*delta
    pos.y = pos.y + math.sin(bullet.transformComponent.rotation)*3000*delta
    bullet:setPosition(pos)
end

return bulletScript