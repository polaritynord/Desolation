local image = {}
local coreFuncs = require("coreFuncs")

function image.new()
    local instance = {
        source = nil;
        position = {0, 0};
        scale = {1, 1};
        rotation = 0;
        parentCanvas = nil;
        align = "xx";
    }

    function instance:draw()
        local src = self.source
        if src == nil then return end
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.align, self.parentCanvas)
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            self.scale[1], self.scale[2], width/2, height/2
        )
    end

    return instance
end

return image