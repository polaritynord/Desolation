local canvas = require("scripts.ui.classes.canvas")

local interfaceManager = {
    canvases = {}
}

function interfaceManager:newCanvas()
    local instance = canvas.new()
    self.canvases[#self.canvases+1] = instance
    instance.index = #self.canvases
    return instance
end

function interfaceManager:update(delta)
    --Update canvases
    for _, v in ipairs(self.canvases) do
        if v.enabled then v:update(delta) end
    end
end

function interfaceManager:draw()
    --Draw canvases
    for _, v in ipairs(self.canvases) do
        if v.enabled then v:draw() end
    end
end

return interfaceManager