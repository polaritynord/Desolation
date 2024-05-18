local rectangle = {}

function rectangle.new()
    local instance = {
        position = {0, 0};
        size = {50, 50};
        color = {1, 1, 1, 1};
        parentComp = nil;
    }

    function instance:draw()
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        love.graphics.rectangle("fill", self.position[1], self.position[2], self.size[1], self.size[2])
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return rectangle