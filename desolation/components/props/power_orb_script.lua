local coreFuncs = require("coreFuncs")
local powerOrbScript = ENGINE_COMPONENTS.scriptComponent.new()

local function drawOrb(comp)
    local camera = CurrentScene.camera
    local pos = coreFuncs.getRelativePosition(comp.parent.position, camera)
    love.graphics.draw(
        comp.source, comp.quad, pos[1], pos[2], comp.parent.rotation,
        camera.zoom, camera.zoom, 10, 10
    )
end

function powerOrbScript:load()
    local orb = self.parent
    --orb properties
    orb.type = "fastFire" or orb.type
    --image component and draw function
    orb.imageComponent = ENGINE_COMPONENTS.imageComponent.new(orb, Assets.mapImages["power_orbs"])
    orb.imageComponent.draw = drawOrb
    orb.imageComponent.quad = love.graphics.newQuad(0, 0, 20, 20, 20, 20)
end

function powerOrbScript:update(delta)
    local orb = self.parent
    local player = CurrentScene.player
end

return powerOrbScript