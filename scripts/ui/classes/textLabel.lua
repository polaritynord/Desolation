local coreFuncs = require("coreFuncs")

local textLabel = {}

function textLabel.new()
    local instance = {
        text = "Eternal Horizons";
        position = {0, 0};
        size = 24;
        align = "xx";
        begin = "left";
        font = "bedstead";
        color = color or {1,1,1,1};
        parentCanvas = nil;
    }

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.align, self.parentCanvas)
        SetFont("assets/fonts/" .. self.font .. ".ttf", self.size)
        
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentCanvas.alpha)
        love.graphics.printf(self.text, pos[1], pos[2], 1000, self.begin)
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return textLabel