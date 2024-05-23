local imageComponent = require("engine.components.image_component")

local bulletScript = {}

function bulletScript:load()
    local bullet = self.parent
    bullet.imageComponent = imageComponent.new(bullet, Assets.images.bullet)
    bullet.imageComponent.layer = 2
end

function bulletScript:update(delta)

end

return bulletScript