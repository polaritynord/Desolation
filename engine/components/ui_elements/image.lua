local image = {}

function image.new()
    local instance = {
        source = Assets.images.icon,
        position = {0, 0};
        scale = {1, 1};
        rotation = 0;
        parentComp = nil;
        color = {1, 1, 1, 1};
    }

    function instance:draw()
        local src = self.source
        if src == nil then return end
        local width = src:getWidth() ;  local height = src:getHeight()

        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        love.graphics.draw(
            src, self.position[1], self.position[2], self.rotation,
            self.scale[1], self.scale[2], width/2, height/2
        )
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return image