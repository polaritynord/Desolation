local image = require("ui.classes.image")
local textLabel = require("ui.classes.textLabel")
local rectangle = require("ui.classes.rectangle")

local canvas = {}

function canvas.new()
    local instance = {
        elements = {};
        enabled = true;
        position = {0, 0};
        alpha = 1;
    }

    function instance:newImage(source, position, scale, rotation, align)
        local instance2 = image.new()
        instance2.source = source
        instance2.position = position
        instance2.scale = scale
        instance2.rotation = rotation
        instance2.align = align
        instance2.parentCanvas = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newTextLabel(text, position, size, align, begin, font, color)
        local instance2 = textLabel.new()
        instance2.text = text
        instance2.position = position
        instance2.size = size
        instance2.align = align
        instance2.begin = begin
        instance2.font = font
        instance2.color = color
        instance2.parentCanvas = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newRectangle(position, size, color, align)
        local instance2 = rectangle.new()
        instance2.position = position
        instance2.size = size
        instance2.color = color
        instance2.align = align
        instance2.parentCanvas = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end
    
    function instance:update()
        --Update elements
        for _, v in ipairs(self.elements) do
            if v.update then v:update() end
        end
    end
    
    function instance:draw()
        --Draw elements
        for _, v in ipairs(self.elements) do
            v:draw()
        end
    end

    return instance
end

return canvas