local image = require("ui.classes.image")

local canvas = {
    elements = {};
    enabled = true;
    position = {0, 0};
}


function canvas:update()
    --Update elements
    for _, v in ipairs(self.elements) do
        if v.update then v:update() end
    end
end

function canvas:draw()
    --Draw elements
    for _, v in ipairs(self.elements) do
        v:draw()
    end
end

return canvas