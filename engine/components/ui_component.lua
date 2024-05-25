local textLabel = require("engine.components.ui_elements.text_label")
local rectangle = require("engine.components.ui_elements.rectangle")
local image = require("engine.components.ui_elements.image")
local textButton = require("engine.components.ui_elements.text_button")
local imageButton = require("engine.components.ui_elements.image_button")

local UIComponent = {}

function UIComponent:new(parent)
    local instance = {
        parent = parent;
        elements = {};
        enabled = true;
        alpha = 1;
    }

    function instance:newTextLabel(attributes)
        local instance2 = textLabel.new()
        if attributes then
            instance2.text = attributes.text or instance2.text
            instance2.position = attributes.position or instance2.position
            instance2.size = attributes.size or instance2.size
            instance2.begin = attributes.begin or instance2.begin
            instance2.font = attributes.font or instance2.font
            instance2.color = attributes.color or instance2.color
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newRectangle(attributes)
        local instance2 = rectangle.new()
        if attributes then
            instance2.position = attributes.position or instance2.position
            instance2.size = attributes.size or instance2.size
            instance2.color = attributes.color or instance2.color
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newImage(attributes)
        local instance2 = image.new()
        if attributes then
            instance2.source = attributes.source or instance2.source
            instance2.position = attributes.position or instance2.position
            instance2.scale = attributes.scale or instance2.scale
            instance2.rotation = attributes.rotation or instance2.rotation
            instance2.color = attributes.color or instance2.color
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newTextButton(attributes)
        local instance2 = textButton.new()
        if attributes then
            instance2.position = attributes.position or instance2.position
            instance2.color = attributes.color or instance2.color
            instance2.buttonText = attributes.buttonText or instance2.buttonText
            instance2.buttonTextSize = attributes.buttonTextSize or instance2.buttonTextSize
            instance2.clickEvent = attributes.clickEvent or instance2.clickEvent
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newImageButton(attributes)
        local instance2 = imageButton.new()
        if attributes then
            instance2.position = attributes.position or instance2.position
            instance2.baseColor = attributes.baseColor or instance2.baseColor
            instance2.textColor = attributes.textColor or instance2.textColor
            instance2.text = attributes.text or instance2.text
            instance2.textSize = attributes.textSize or instance2.textSize
            instance2.baseScale = attributes.baseScale or instance2.baseScale
            instance2.clickEvent = attributes.clickEvent or instance2.clickEvent
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:update(delta)
        --Update elements
        for _, v in ipairs(self.elements) do
            if v.update then v:update(delta) end
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

return UIComponent