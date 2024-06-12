local textLabel = require("engine.components.ui_elements.text_label")
local rectangle = require("engine.components.ui_elements.rectangle")
local image = require("engine.components.ui_elements.image")
local textButton = require("engine.components.ui_elements.text_button")
local imageButton = require("engine.components.ui_elements.image_button")
local checkbox = require("engine.components.ui_elements.checkbox")
local slider = require("engine.components.ui_elements.slider")

local UIComponent = {}

function UIComponent:new(parent)
    local instance = {
        name = "UIComponent";
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
        if attributes.source == "none" then
            instance2.source = nil
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
            instance2.hoverEvent = attributes.hoverEvent or instance2.hoverEvent
            instance2.unhoverEvent = attributes.unhoverEvent or instance2.unhoverEvent
            instance2.begin = attributes.begin or instance2.begin
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
            instance2.hoverEvent = attributes.hoverEvent or instance2.hoverEvent
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newCheckbox(attributes)
        local instance2 = checkbox.new()
        if attributes then
            instance2.position = attributes.position or instance2.position
            instance2.size = attributes.size or instance2.size
            instance2.toggled = attributes.toggled or instance2.toggled
            instance2.clickEvent = attributes.clickEvent or instance2.clickEvent
            instance2.hoverEvent = attributes.hoverEvent or instance2.hoverEvent
            instance2.unhoverEvent = attributes.unhoverEvent or instance2.unhoverEvent
            instance2.color = attributes.color or instance2.color
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:newSlider(attributes)
        local instance2 = slider.new()
        if attributes then
            instance2.position = attributes.position or instance2.position
            instance2.baseSize = attributes.baseSize or instance2.baseSize
            instance2.baseColor = attributes.baseColor or instance2.baseColor
            instance2.stickColor = attributes.stickColor or instance2.stickColor
            instance2.value = attributes.value or instance2.value
        end
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    function instance:update(delta)
        if not self.enabled then return end
        --Update elements
        for _, v in ipairs(self.elements) do
            if v.update and v.enabled then v:update(delta) end
        end
    end

    function instance:draw()
        if not self.enabled then return end
        --Draw elements
        for _, v in ipairs(self.elements) do
            if v.enabled then v:draw() end
        end
    end

    return instance
end

return UIComponent