local coreFuncs = require("coreFuncs")

local imageButton = {}

function imageButton.new()
    local instance = {
        position = {0, 0};
        color = {1, 1, 1, 1};
        scale = {1, 1};
        rotation = 0;
        source = Assets.defaultImages.missing_texture;
        parentComp = nil;
        mouseHovering = false;
        mouseClicking = false;
        clickEvent = nil;
        hoverEvent = nil;
        unhoverEvent = nil;
        bindedKey = nil;
        enabled = true;
    }

    function instance:update(delta)
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        --Click event
        if (love.mouse.isDown(1) and self.mouseHovering and not self.mouseClicking) and self.clickEvent ~= nil and InputManager.inputType == "keyboard" then
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
        local w = self.source:getWidth()*self.scale[1]
        local h = self.source:getHeight()*self.scale[2]
        if coreFuncs.aabbCollision({pos[1]-w/2, pos[2]-h/2}, {mx, my}, {w, h}, {1, 1}) then
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
        love.graphics.push()
            local w = self.source:getWidth()
            local h = self.source:getHeight()
            love.graphics.setColor(unpack(self.color))
            love.graphics.draw(
                self.source, pos[1], pos[2], self.rotation, self.scale[1], self.scale[2],
                w/2, h/2
            )
        love.graphics.pop()
    end

    return instance
end

return imageButton