local coreFuncs = require("coreFuncs")
local buttonEvents = require("desolation.button_clickevents")

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
        hoverEvent = buttonEvents.defaultHoverEvent;
        unhoverEvent = buttonEvents.defaultUnhoverEvent;
        bindedKey = nil;
        textFont = "disposable-droid";
        enabled = true;
        begin = "left";
    }

    function instance:update(delta)
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        --Click event
        if ((love.mouse.isDown(1) and self.mouseHovering and not self.mouseClicking) or self.bindedKey ~= nil and love.keyboard.isDown(self.bindedKey)) and self.clickEvent and InputManager.leftMouseTimer > 0.25 and InputManager.inputType == "keyboard" then
            InputManager.leftMouseTimer = 0
            SoundManager:playSound(Assets.defaultSounds["button_click"], Settings.vol_sfx)
            self.clickEvent(self)
        end
        --Check for controller selection
        local cursorUI = CurrentScene.cursor.UIComponent
        if InputManager.inputType == "joystick" and cursorUI.controllerCurrentMenu ~= nil then
            local selectedButton = cursorUI.controllerCurrentMenu.controllerButtons[cursorUI.controllerSelection]
            if selectedButton == instance then
                if self.hoverEvent then self.hoverEvent(self) end
            else
                if self.unhoverEvent then self.unhoverEvent(self) end
            end
        end
        --Check for mouse touch
        if InputManager.inputType ~= "keyboard" then return end
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