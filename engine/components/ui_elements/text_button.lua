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
        unhoverEvent = nil;
        bindedKey = nil;
        textFont = "disposable-droid";
        enabled = true;
        begin = "left";
    }

    function instance.hoverEvent(element)
        local delta = love.timer.getDelta()
        element.hoverOffset = element.hoverOffset + (14-element.hoverOffset) * 27 * delta
        if element.mouseHovering then return end
        SoundManager:playSound(Assets.defaultSounds["button_hover"], Settings.vol_sfx)
    end

    function instance.unhoverEvent(element)
        local delta = love.timer.getDelta()
        element.hoverOffset = element.hoverOffset + (0-element.hoverOffset) * 27 * delta
    end

    function instance:update(delta)
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)

        --Click event
        if ((love.mouse.isDown(1) and self.mouseHovering and not self.mouseClicking) or self.bindedKey ~= nil and love.keyboard.isDown(self.bindedKey)) and self.clickEvent and InputManager.leftMouseTimer > 0.25 then
            InputManager.leftMouseTimer = 0
            SoundManager:playSound(Assets.defaultSounds["button_click"], Settings.vol_sfx)
            self.clickEvent(self)
        end
        --Check for mouse touch
        if my > pos[2] and my < pos[2] + self.buttonTextSize and mx > pos[1] and mx < pos[1] + 200 then
            if self.hoverEvent then self.hoverEvent(self) end
            self.mouseHovering = true
            self.mouseClicking = love.mouse.isDown(1)
        else
            if self.unhoverEvent then self.unhoverEvent(self) end
            self.mouseHovering = false
            self.mouseClicking = false
        end
    end

    function instance:draw()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        SetFont("desolation/assets/fonts/" .. self.textFont .. ".ttf", self.buttonTextSize)
        love.graphics.printf(self.buttonText, pos[1]+self.hoverOffset, pos[2], 1000, self.begin)
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return textButton