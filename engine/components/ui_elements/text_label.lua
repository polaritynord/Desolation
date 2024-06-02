local coreFuncs = require("coreFuncs")

local textLabel = {}

function textLabel.new()
    local instance = {
        text = "Lorem ipsum dolor sit amet";
        position = {0, 0};
        size = 24;
        begin = "left";
        font = "disposable-droid";
        color = {1,1,1,1};
        parentComp = nil;
        wrapLimit = 1000;
        enabled = true;
    }

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        SetFont("desolation/assets/fonts/" .. self.font .. ".ttf", self.size)
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        love.graphics.printf(self.text, pos[1], pos[2], self.wrapLimit, self.begin)
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return textLabel