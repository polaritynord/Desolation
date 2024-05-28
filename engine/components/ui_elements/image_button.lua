local coreFuncs = require("coreFuncs")

local imageButton = {}

function imageButton.new()
    local instance = {
        position = {0, 0};
        baseColor = {0, 0, 0, 1};
        textColor = {1, 1, 1, 1};
        text = "Button";
        parentComp = nil;
        textSize = 24;
        mouseHovering = false;
        mouseClicking = false;
        clickEvent = nil;
        hoverEvent = nil;
        font = "disposable-droid";
        baseScale = {100, 50};
        wrapLimit = 1000;
        enabled = true;
    }

    function instance:update(delta)
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)

        --Click event
        if love.mouse.isDown(1) and self.mouseHovering and not self.mouseClicking and self.clickEvent then
            love.audio.play(Assets.sounds.sfx.buttonClick)
            self.clickEvent(self)
        end

        --check for mouse touch
        if my > pos[2] and my < pos[2] + self.baseScale[2] and mx > pos[1] and mx < pos[1] + self.baseScale[1] then
            if self.hoverEvent then self.hoverEvent(self) end
            self.mouseHovering = true
            self.mouseClicking = love.mouse.isDown(1)
        else
            self.mouseHovering = false
            self.mouseClicking = false
        end
    end

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        --draw base
        love.graphics.setColor(self.baseColor[1], self.baseColor[2], self.baseColor[3], self.baseColor[4]*self.parentComp.alpha)
        love.graphics.rectangle("fill", pos[1], pos[2], self.baseScale[1], self.baseScale[2])
        
        --draw text
        SetFont("fdh/assets/fonts/" .. self.font .. ".ttf", self.textSize)
        love.graphics.setColor(self.textColor[1], self.textColor[2], self.textColor[3], self.textColor[4]*self.parentComp.alpha)
        love.graphics.printf(self.text, pos[1], pos[2], self.wrapLimit, "left")
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return imageButton