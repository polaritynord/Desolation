local assets = require("assets")

local player = {}

function player.new()
    local instance = {
        position = {0, 0};
        rotation = 0;
    }

    function instance:load()

    end

    function instance:update(delta)

    end

    function instance:draw()
        -- Draw body
        local src = assets.images.player.body
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = {self.position[1], self.position[2]}
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            1, 1, width/2, height/2
        )
    end

    return instance
end

return player