local coreFuncs = require "coreFuncs"

local rectangle = {}

function rectangle.new()
    local instance = {
        position = {0, 0};
        size = {50, 50};
        color = {1, 1, 1, 1};
        parentComp = nil;
        enabled = true;
        drawType = "fill";
        lineWidth = 1;
    }

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        love.graphics.setLineWidth(self.lineWidth)
        love.graphics.rectangle(self.drawType, pos[1], pos[2], self.size[1], self.size[2])
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return rectangle