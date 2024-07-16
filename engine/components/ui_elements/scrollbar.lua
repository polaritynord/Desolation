local coreFuncs = require "coreFuncs"
local scrollBar = {}

function scrollBar.new()
    local instance = {
        parentComp = nil;
        position = {0, 0};
        enabled = true;
        baseSize = {20, 200};
        baseColor = {0.5, 0.5, 0.5, 1};
        barColor = {1, 0, 0, 1};
        value = 0;
        mouseHovering = false;
        maxValue = 3;
    }

    function instance:update()
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        local barSize = {self.baseSize[1], self.baseSize[2]/10}
        local barPos = {pos[1], pos[2] + self.value*self.baseSize[2]}
        if love.mouse.isDown(1) then
            if self.mouseHovering then
                local dy = my - pos[2] - barSize[2]/2
                self.value = dy / self.baseSize[2]
            end
        else
            self.mouseHovering = my > barPos[2] and my < barPos[2]+barSize[2] and mx > barPos[1] and mx < barPos[1] + barSize[1]
        end
        if self.value < 0 then self.value = 0 end
        if self.value > self.maxValue - (barSize[2]/self.baseSize[2]) then self.value = self.maxValue - (barSize[2]/self.baseSize[2]) end
    end

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        local barSize = {self.baseSize[1], self.baseSize[2]/10}
        local barPos = {pos[1], pos[2] + self.value*self.baseSize[2]}
        --draw base
        love.graphics.setColor(self.baseColor[1], self.baseColor[2], self.baseColor[3], self.baseColor[4]*self.parentComp.alpha)
        love.graphics.rectangle("fill", pos[1], pos[2], self.baseSize[1], self.baseSize[2])
        --draw bar
        love.graphics.setColor(self.barColor[1], self.barColor[2], self.barColor[3], self.barColor[4]*self.parentComp.alpha)
        love.graphics.rectangle("fill", barPos[1], barPos[2], barSize[1], barSize[1])
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return scrollBar