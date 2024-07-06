local coreFuncs = require "coreFuncs"
local bulletLineRenderer = ENGINE_COMPONENTS.scriptComponent.new()

local function drawLines(comp)
    love.graphics.setLineStyle("rough")
    for _, line in ipairs(comp.parent.lines) do
        love.graphics.setColor(line[4])
        love.graphics.setLineWidth(line[3]*CurrentScene.camera.zoom)
        local pos1 = coreFuncs.getRelativePosition(line[1], CurrentScene.camera)
        local pos2 = coreFuncs.getRelativePosition(line[2], CurrentScene.camera)
        love.graphics.line(
            pos1[1], pos1[2], pos2[1], pos2[2]
        )
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function bulletLineRenderer:load()
    self.parent.lines = {}
    self.parent.imageComponent.draw = drawLines
end

function bulletLineRenderer:update(delta)
    for i, line in ipairs(self.parent.lines) do
        line[3] = line[3] + (-line[3])*18*delta
        if line[3] < 0.1 then
            table.remove(self.parent.lines, i)
        end
    end
end

return bulletLineRenderer