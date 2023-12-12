local coreFuncs = require("coreFuncs")

local rectangle = {}

function rectangle.new()
    local instance = {
        position = {0, 0};
        size = {45, 45};
        align = "xx";
        color = {1, 1, 1, 1};
        parentCanvas = nil;
    }

    function instance:draw()
        print(98)
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.align, self.parentCanvas)

        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentCanvas.alpha)
        love.graphics.rectangle("fill", pos[1], pos[2], self.size[1], self.size[2])
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return rectangle