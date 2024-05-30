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
        hoverEvent = nil;
        textFont = "disposable-droid";
        enabled = true;
    }

    function instance.hoverEvent(element)
        if element.mouseHovering then return end
        love.audio.play(Assets.sounds.sfx.buttonHover)
    end

    function instance:update(delta)
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)

        --Click event
        if love.mouse.isDown(1) and self.mouseHovering and not self.mouseClicking and self.clickEvent then
            love.audio.play(Assets.sounds.sfx.buttonClick)
            self.clickEvent(self)
        end
        --Check for mouse touch
        if my > pos[2] and my < pos[2] + self.buttonTextSize and mx > pos[1] and mx < pos[1] + 200 then
            if self.hoverEvent then self.hoverEvent(self) end
            self.mouseHovering = true
            self.mouseClicking = love.mouse.isDown(1)
            --TODO move these hovering stuff to hoverEvent?
            self.hoverOffset = self.hoverOffset + (14-self.hoverOffset) * 27 * delta
        else
            self.mouseHovering = false
            self.mouseClicking = false
            self.hoverOffset = self.hoverOffset + (0-self.hoverOffset) * 27 * delta
        end
    end

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        SetFont("fdh/assets/fonts/" .. self.textFont .. ".ttf", self.buttonTextSize)
        love.graphics.printf(self.buttonText, pos[1]+self.hoverOffset, pos[2], 1000, "left")
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return textButton