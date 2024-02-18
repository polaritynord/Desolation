local camera = {}

function camera.new()
    local instance = {
        position = {0, 0},
        zoom = 1;
        oldMouseX = 0 ; oldMouseY = 0;
    }

    function instance:followTarget(target, smoothness, delta)
        local x = (target.position[1]-self.position[1])
        local y = (target.position[2]-self.position[2])
        self.position[1] = self.position[1] + x*smoothness*delta
        self.position[2] = self.position[2] + y*smoothness*delta
    end

    function instance:freecamControls()
        local mx, my = love.mouse.getPosition()
        if love.mouse.isDown(3) then
            self.position[1] = self.position[1] + (self.oldMouseX-mx)
            self.position[2] = self.position[2] + (self.oldMouseY-my)
        end
        self.oldMouseX = mx
        self.oldMouseY = my
    end

    return instance
end

return camera