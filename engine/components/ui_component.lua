local textLabel = require("engine.components.ui_elements.text_label")

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