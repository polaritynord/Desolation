local coreFuncs = require("coreFuncs")

local wallScript = ENGINE_COMPONENTS.scriptComponent.new()

local function noCenteredDraw(self)
    if not self.source then return end
    local object = self.parent
    local camera = CurrentScene.camera
    local pos = coreFuncs.getRelativePosition(object.position, camera)
    love.graphics.setColor(self.color)
    love.graphics.draw(
        self.source, self.quad, pos[1], pos[2], object.rotation,
        camera.zoom, camera.zoom
    )
end

function wallScript:load()
    local wall = self.parent
    wall.imageComponent = ENGINE_COMPONENTS.imageComponent.new(wall, Assets.mapImages["wall_" .. wall.name])
    wall.imageComponent.layer = 4
    wall.imageComponent.source:setWrap("repeat", "repeat")
    wall.imageComponent.quad = love.graphics.newQuad(0, 0, wall.scale[1]*64, wall.scale[2]*64, 64, 64)
    wall.imageComponent.draw = noCenteredDraw
    wall.imageComponent.depth = 5
end

function wallScript:update(delta)
    
end

return wallScript