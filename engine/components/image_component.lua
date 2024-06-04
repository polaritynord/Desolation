local coreFuncs = require("coreFuncs")

local imageComponent = {}

function imageComponent.new(parent, source)
    local component = {
        parent = parent;
        name = "imageComponent";
        source = source or Assets.images.missingTexture;
        layer = 1;
        color = {1, 1, 1, 1};
    }

    function component:draw()
        if not self.source then return end
        love.graphics.setColor(self.color)
        local object = self.parent
        local camera = CurrentScene.camera
        local w, h = self.source:getWidth(), self.source:getHeight()
        local pos = coreFuncs.getRelativePosition(object.position, camera)
        love.graphics.draw(
            self.source, pos[1], pos[2], object.rotation,
            object.scale[1]*camera.zoom, object.scale[2]*camera.zoom, w/2, h/2
        )
    end

    return component
end

return imageComponent