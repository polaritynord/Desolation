local prop = {}

function prop.new()
    local newProp = {
        position = {0, 0};
        size = {1, 1};
        rotation = 0;
    }
    
    return newProp
end

return prop