local camera = {}

function camera.new()
    local instance = {
        position = {0, 0},
        zoom = 1;
    }

    function instance:followTarget(target, smoothness)

    end
    
    return instance
end

return camera