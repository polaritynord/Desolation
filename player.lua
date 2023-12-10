local assets = require("assets")
local coreFuncs = require("coreFuncs")

local player = {}

function player.new()
    local instance = {
        position = {0, 0};
        velocity = {0, 0};
        rotation = 0;
        health = 100;
        armor = 100;
    }

    function instance:drawHands()
        local src = assets.images.player.handDefault
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        --Move hands forward a bit
        pos[1] = pos[1] + math.cos(self.rotation) * 20
        pos[2] = pos[2] + math.sin(self.rotation) * 20
        --Draw
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            2.8, 2.8, width/2, height/2
        )
    end

    function instance:movement(delta)
        local speed = 140
        self.velocity = {0, 0}
        --Get key input
        if love.keyboard.isDown("a") then
            self.velocity[1] = self.velocity[1] - 1
        end
        if love.keyboard.isDown("d") then
            self.velocity[1] = self.velocity[1] + 1
        end
        if love.keyboard.isDown("w") then
            self.velocity[2] = self.velocity[2] - 1
        end
        if love.keyboard.isDown("s") then
            self.velocity[2] = self.velocity[2] + 1
        end
        --Normalize velocity
        if math.abs(self.velocity[1]) == math.abs(self.velocity[2]) then
            self.velocity[1] = self.velocity[1] * math.sin(math.pi/4)
            self.velocity[2] = self.velocity[2] * math.sin(math.pi/4)
        end
        --Move by velocity
        self.position[1] = self.position[1] + (self.velocity[1]*speed*delta)
        self.position[2] = self.position[2] + (self.velocity[2]*speed*delta)
    end

    function instance:pointTowardsMouse()
        local mouseX, mouseY = love.mouse.getPosition()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        local dx = mouseX-pos[1] ; local dy = mouseY-pos[2]
        self.rotation = math.atan2(dy, dx)
    end

    --Core functions
    function instance:load()

    end

    function instance:update(delta)
        self:movement(delta)
        self:pointTowardsMouse()
        Camera:followTarget(self, 8, delta)
    end

    function instance:draw()
        --Draw hands
        self:drawHands()
        -- Draw body
        local src = assets.images.player.body
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            4, 4, width/2, height/2
        )
    end

    return instance
end

return player