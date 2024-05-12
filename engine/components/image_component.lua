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
        local w, h = self.source:getWidth()/2, self.source:getHeight()/2
        local camTransform = CurrentScene.camera.transformComponent
        love.graphics.draw(
            self.source, transform.x, transform.y, transform.rotation,
            transform.scale.x, transform.scale.y, w, h
        )
    end

    return component
end

return imageComponent