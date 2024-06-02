local coreFuncs = require("coreFuncs")

local debugMenu = {}

function debugMenu:load()
    local ui = self.parent.UIComponent
    ui.debugTextsLeft = ui:newTextLabel({size=20, position={5, 5}})
    ui.debugTextsRight = ui:newTextLabel({size=20, begin="right", position={-48, 5}})
    self.parent.enabled = false
    self.parent.verboseMode = false
end

function debugMenu:update(delta)
    local ui = self.parent.UIComponent
    ui.enabled = self.parent.enabled
    --Update texts
    local fps = love.timer.getFPS()
    local playerPos = CurrentScene.player:getPosition()
    local averageFps = math.ceil(1/love.timer.getAverageDelta())
    local mx, my = love.mouse.getPosition()
    local rmx, rmy = coreFuncs.getRelativeMousePosition()
    --write vsync next to fps counter if enabled
    local fps_suffix
    if love.window.getVSync() == 1 then
        fps_suffix = " (VSync ON)"
    else
        fps_suffix = " (VSync OFF)"
    end
    --Update debug text
    ui.debugTextsLeft.text = GAME_NAME .. " - Made by " .. AUTHOR .. "\n"
                        .. "FPS: " .. fps .. "/" .. averageFps .. fps_suffix ..
                        "\nPlayer Coordinates: X=" .. math.floor(playerPos.x) .. " Y=" .. math.floor(playerPos.y) .. "\n" ..
                        "Memory Used(Excluding Love2D): " .. coreFuncs.roundDecimal(collectgarbage("count")/1024, 2) .. " MB"
                        .. "\nMouse Position: X=" .. mx .. " Y=" .. my .. "\nRelative Mouse Position: X=" .. rmx .. " Y=" .. rmy ..
                        "\nParticle Count: " .. CurrentScene.particleCount .. "\nItem Count: " .. #CurrentScene.items.tree ..
                        "\nBullet Count: " .. #CurrentScene.bullets.tree
    ui.debugTextsRight.text = GAME_VERSION_STATE .. " " .. GAME_VERSION .. "\nPowered by " .. ENGINE_NAME .. " (Build " .. ENGINE_VERSION .. ")"
    --TODO additional debug info to add: particle count, humanoid count
end

return debugMenu