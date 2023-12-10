local canvas = require("ui.classes.canvas")

local interfaceManager = {
    canvases = {}
}

function interfaceManager:newCanvas()
    local instance = canvas.new()
    self.canvases[#self.canvases+1] = instance
    return instance
end

function interfaceManager:update()
    --Update canvases
    for _, v in ipairs(self.canvases) do
        if v.enabled then v:update() end
    end
end

function interfaceManager:draw()
    --Draw canvases
    for _, v in ipairs(self.canvases) do
        if v.enabled then v:draw() end
    end
end

return interfaceManager