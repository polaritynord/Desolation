local coreFuncs = require("coreFuncs")

local expText = ENGINE_COMPONENTS.scriptComponent.new()

local function textDraw(comp)
    local prop = comp.parent
    local pos = coreFuncs.getRelativePosition(prop.position, CurrentScene.camera)
    SetFont("desolation/assets/fonts/" .. prop.font .. ".ttf", 32)
    love.graphics.setColor(comp.color[1], comp.color[2], comp.color[3], comp.color[4])
    love.graphics.printf(prop.text, pos[1], pos[2], 1000, "left")
    love.graphics.setColor(1, 1, 1, 1)
end

function expText:load()
    local prop = self.parent
    prop.imageComponent = ENGINE_COMPONENTS.imageComponent.new(prop)
    prop.imageComponent.draw = textDraw
end

function expText:update(delta)
end

return expText