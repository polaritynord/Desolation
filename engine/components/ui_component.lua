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
        instance2.text = attributes.text or instance2.text
        instance2.position = attributes.position or instance2.position
        instance2.size = attributes.size or instance2.size
        instance2.begin = attributes.begin or instance2.begin
        instance2.font = attributes.font or instance2.font
        instance2.color = attributes.color or instance2.color
        instance2.parentComp = self
        self.elements[#self.elements+1] = instance2
        return instance2
    end

    return instance
end

return UIComponent