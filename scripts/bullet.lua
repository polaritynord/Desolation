local assets = require("assets")
local coreFuncs = require("coreFuncs")

local bullet = {}

function bullet.new()
    local instance = {
        position = {0, 0};
        rotation = 0;
        lifetime = 1;
        timer = 0;
        speed = 700;
    }

    function instance:update(delta, i)
        self.timer = self.timer + delta
        --Check for despawn
        if self.timer > self.lifetime then
            table.remove(MapManager.bullets, i)
            return
        end
        --Movement
        self.position[1] = self.position[1] + math.cos(self.rotation)*self.speed*delta
        self.position[2] = self.position[2] + math.sin(self.rotation)*self.speed*delta
    end

    function instance:draw()
        local src = assets.images.player.body
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        --Draw image
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            1*Camera.zoom, 1*Camera.zoom, width/2, height/2
        )
    end

    return instance
end

return bullet