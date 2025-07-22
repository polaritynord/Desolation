local coreFuncs = require("coreFuncs")
local textScript = ENGINE_COMPONENTS.scriptComponent.new()

local function textDraw(comp)
    local prop = comp.parent
    love.graphics.push()
        love.graphics.setColor(prop.color)
        local pos = coreFuncs.getRelativePosition(prop.position, CurrentScene.camera)
        SetFont("desolation/assets/fonts/" .. prop.font .. ".ttf", 30)
        love.graphics.printf(
            prop.text, pos[1], pos[2], prop.wrapLimit, "left", prop.rotation,
            prop.scale[1]*CurrentScene.camera.zoom, prop.scale[2]*CurrentScene.camera.zoom,
            0, 0
        )
    love.graphics.pop()
end

function textScript:load()
    local prop = self.parent
    prop.imageComponent = ENGINE_COMPONENTS.imageComponent.new(prop, nil)
    prop.imageComponent.draw = textDraw
    prop.imageComponent.layer = 4
    prop.text = prop.text or "HELLO WORLD"
    prop.minDistance = prop.minDistance or 100
    prop.color = prop.color or {1, 1, 1, 1}
    prop.wrapLimit = prop.wrapLimit or 1000
    prop.font = prop.font or "disposable-droid"
    prop.oldAlpha = prop.color[4]
end

function textScript:update(delta)
    --TODO add centered text, proper distance check and alpha changing
end

return textScript