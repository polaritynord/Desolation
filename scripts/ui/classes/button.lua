local coreFuncs = require("coreFuncs")

local button = {}

function button.new()
    local instance = {
        position = {0, 0};
        size = {30, 70};
        align = "xx";
        color = {1, 1, 1, 1};
        buttonType = 1;
        parentCanvas = nil;
        buttonText = "Button";
        buttonTextSize = 24;
        mouseHovering = false;
        hoverOffset = 0;
    }

    function instance:update(delta)
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.align, self.parentCanvas)
        local mX, mY = love.mouse.getPosition()

        if self.buttonType == 1 then
            --Check for mouse touch
            if mY > pos[2] and mY < pos[2] + self.buttonTextSize then
                self.mouseHovering = true
                self.hoverOffset = self.hoverOffset + (14-self.hoverOffset) * 40 * delta
            else
                self.mouseHovering = false
                self.hoverOffset = self.hoverOffset + (0-self.hoverOffset) * 40 * delta
            end
            print(self.mouseHovering)
        end
    end

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.align, self.parentCanvas)

        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentCanvas.alpha)
        if self.buttonType == 1 then
            --Simple text button
            SetFont("assets/fonts/" .. self.font .. ".ttf", self.buttonTextSize)
            love.graphics.printf(self.buttonText, pos[1]+self.hoverOffset, pos[2], 1000, "left")
        end
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return button