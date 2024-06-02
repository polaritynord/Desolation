local coreFuncs = require("coreFuncs")

local slider = {}

function slider.new()
    local instance = {
        parentComp = nil;
        position = {600, 40};
        baseSize = {200, 20};
        baseColor = {0, 0, 0, 1};
        stickColor = {1, 1, 1, 1};
        value = 0;
        enabled = true;
        font = "disposable-droid";
    }

    function instance:update()
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)

        --Check for mouse touch
        if my > pos[2] and my < pos[2] + self.baseSize[2] and mx > pos[1] and mx < pos[1] + self.baseSize[1] and love.mouse.isDown(1) then
            local dx = mx - pos[1]
            self.value = dx / self.baseSize[1]
            if self.value < 0.04 then self.value = 0 end
            if self.value > 0.96 then self.value = 1 end
        end
    end

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        --draw base
        love.graphics.setColor(self.baseColor[1], self.baseColor[2], self.baseColor[3], self.baseColor[4]*self.parentComp.alpha)
        love.graphics.rectangle("fill", pos[1], pos[2], self.baseSize[1], self.baseSize[2])
        --draw stick
        love.graphics.setColor(self.stickColor[1], self.stickColor[2], self.stickColor[3], self.stickColor[4]*self.parentComp.alpha)
        love.graphics.rectangle("fill", pos[1], pos[2], self.value*self.baseSize[1], self.baseSize[2])
        --draw value percentage
        love.graphics.setColor(0, 0, 0, 1)
        SetFont("desolation/assets/fonts/" .. self.font .. ".ttf", 12)
        love.graphics.printf(math.floor(self.value*100) .. "%", pos[1], pos[2], 1000, "left")
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return slider