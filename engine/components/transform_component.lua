local transformComponent = {}

function transformComponent.new(parent)
    local t = {
        x = 0; y = 0;
        parent = parent;
        rotation = 0;
        scale = {x=1, y=1};
    }

    return t
end

return transformComponent