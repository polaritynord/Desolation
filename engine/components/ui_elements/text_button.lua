local coreFuncs = require("coreFuncs")

local textButton = {}

function textButton.new()
    local instance = {
        position = {0, 0};
        color = {1, 1, 1, 1};
        parentComp = nil;
        buttonText = "Button";
        buttonTextSize = 24;
        mouseHovering = false;
        mouseClicking = false;
        hoverOffset = 0;
        clickEvent = nil;
    }

    function instance:update(delta)
        local mx, my = coreFuncs.getRelativeMousePosition()

        --Click event
        if love.mouse.isDown(1) and self.mouseHovering and not self.mouseClicking and self.clickEvent then
            self.clickEvent(self)
        end
        --Check for mouse touch
        if my > self.position[2] and my < self.position[2] + self.buttonTextSize and mx > self.position[1] and mx < self.position[1] + 200 then
            self.mouseHovering = true
            self.mouseClicking = love.mouse.isDown(1)
            self.hoverOffset = self.hoverOffset + (14-self.hoverOffset) * 27 * delta
        else
            self.mouseHovering = false
            self.mouseClicking = false
            self.hoverOffset = self.hoverOffset + (0-self.hoverOffset) * 27 * delta
        end
    end

    function instance:draw()
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        SetFont("fdh/assets/fonts/disposable-droid.ttf", self.buttonTextSize)
        love.graphics.printf(self.buttonText, self.position[1]+self.hoverOffset, self.position[2], 1000, "left")
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return textButton