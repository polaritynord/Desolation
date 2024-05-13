local coreFuncs = require("coreFuncs")

local imageComponent = {}

function imageComponent.new(parent, source)
    local component = {
        parent = parent;
        source = source or Assets.images.icon;
    }

    function component:draw()
        if not self.source then return end
        love.graphics.setColor(1, 1, 1, 1)
        local transform = self.parent.transformComponent
        local camera = CurrentScene.camera
        local w, h = self.source:getWidth(), self.source:getHeight()
        local pos = coreFuncs.getRelativePosition(transform, camera)
        love.graphics.draw(
            self.source, pos[1], pos[2], transform.rotation,
            transform.scale.x*camera.zoom, transform.scale.y*camera.zoom, w/2, h/2
        )
    end

    return component
end

return imageComponent