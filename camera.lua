local camera = {}

function camera.new()
    local instance = {
        position = {0, 0},
        zoom = 1;
    }

    function instance:followTarget(target, smoothness, delta)
        local x = (target.position[1]-self.position[1])
        local y = (target.position[2]-self.position[2])
        self.position[1] = self.position[1] + x*smoothness*delta
        self.position[2] = self.position[2] + y*smoothness*delta
    end

    return instance
end

return camera