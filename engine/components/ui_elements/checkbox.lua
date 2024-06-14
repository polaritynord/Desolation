local coreFuncs = require("coreFuncs")

local checkbox = {}

function checkbox.new()
    local instance = {
        position = {50, 50};
        size = {20, 20};
        realSize = {20, 20};
        toggled = false;
        enabled = true;
        clickEvent = nil;
        color = {1, 1, 1, 1};
        parentComp = nil;
        lineWidth = 4;
        mouseHovering = false;
        mouseClicking = false;
    }

    function instance.hoverEvent(element)
        local delta = love.timer.getDelta()
        element.size[1] = element.size[1] + (element.realSize[1]+5-element.size[1]) * 8.25 * delta
        element.size[2] = element.size[2] + (element.realSize[2]+5-element.size[2]) * 8.25 * delta
    end

    function instance.unhoverEvent(element)
        local delta = love.timer.getDelta()
        element.size[1] = element.size[1] + (element.realSize[1]-element.size[1]) * 8.25 * delta
        element.size[2] = element.size[2] + (element.realSize[2]-element.size[2]) * 8.25 * delta
    end

    function instance:update()
        local mx, my = coreFuncs.getRelativeMousePosition()
        local pos = coreFuncs.getRelativeElementPosition(self.position, self.parentComp)
        pos[1] = pos[1] - self.size[1]/2
        pos[2] = pos[2] - self.size[2]/2

        --Click event
        if love.mouse.isDown(1) and self.mouseHovering and not self.mouseClicking then
            --TODO change this sound to something else?
            self.toggled = not self.toggled
            love.audio.play(Assets.defaultSounds["button_click"])
            if self.clickEvent then self.clickEvent(self) end
        end
        
        --check for mouse touch
        if my > pos[2] and my < pos[2] + self.size[2] and mx > pos[1] and mx < pos[1] + self.size[1] then
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
        pos[1] = pos[1] - self.size[1]/2
        pos[2] = pos[2] - self.size[2]/2
        --draw outline
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.color[4]*self.parentComp.alpha)
        love.graphics.setLineWidth(self.lineWidth)
        love.graphics.rectangle("line", pos[1], pos[2], self.size[1], self.size[2])
        --draw inside
        if self.toggled then
            love.graphics.rectangle("fill", pos[1], pos[2], self.size[1], self.size[2])
        end
        love.graphics.setColor(1, 1, 1, 1)
    end

    return instance
end

return checkbox