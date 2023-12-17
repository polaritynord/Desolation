local assets = require("assets")
local coreFuncs = require("coreFuncs")

local humanoid = {}

function humanoid.new()
    local instance = {
        position = {0, 0};
        velocity = {0, 0};
        rotation = 0;
        health = 100;
        armor = 100;
        sprinting = false;
        moving = false;
        animationSizeDiff = 0; --Used in walk animation
        inventory = {
            weapons = {nil, nil, nil};
            items = {};
            slot = 1;
        };
    }

    --Changes the size of player with a sin wave.
    function instance:doWalkingAnim()
        if not self.moving then return end
        local time = love.timer.getTime()
        local speed = 12
        if self.sprinting then speed = speed + 4 end
        self.animationSizeDiff = math.sin(time*speed)/5
    end

    function instance:drawHands()
        local src = assets.images.player.handDefault
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        --Move hands forward a bit
        pos[1] = pos[1] + math.cos(self.rotation) * 20 * Camera.zoom
        pos[2] = pos[2] + math.sin(self.rotation) * 20 * Camera.zoom
        --Draw
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            2.8*Camera.zoom + self.animationSizeDiff/2, 2.8*Camera.zoom + self.animationSizeDiff/2, width/2, height/2
        )
    end

    function instance:load()
        --Create item slots in inventory
        for i = 1, 40 do
            self.inventory.items[#self.inventory.items+1] = {}
        end
    end

    return instance
end

return humanoid