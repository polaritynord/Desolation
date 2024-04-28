local assets = require("assets")
local coreFuncs = require("coreFuncs")
local humanoidSounds = require("scripts.humanoidSounds")

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
        handOffset = 0;
        inventory = {
            weapons = {nil, nil, nil};
            items = {};
            ammunition = {
                light = 0;
                medium = 0;
                heavy = 0;
            };
            slot = 1;
        };
        sounds = humanoidSounds.new();
        shootTimer = 0;
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
        --Get current hand image
        local src = assets.images.player.handDefault
        if self.inventory.weapons[self.inventory.slot] then
            src = assets.images.player.handWeapon --Placeholder
        end

        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        --Move hands forward a bit
        pos[1] = pos[1] + math.cos(self.rotation) * 20 * Camera.zoom
        pos[2] = pos[2] + math.sin(self.rotation) * 20 * Camera.zoom
        --Offsetting
        pos[1] = pos[1] + math.cos(self.rotation) * self.handOffset * Camera.zoom
        pos[2] = pos[2] + math.sin(self.rotation) * self.handOffset * Camera.zoom
        --Draw
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            2.8*Camera.zoom + self.animationSizeDiff/2, 2.8*Camera.zoom + self.animationSizeDiff/2, width/2, height/2
        )
    end

    return instance
end

return humanoid