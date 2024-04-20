local weaponManager = require("scripts.weaponManager")
local coreFuncs = require("coreFuncs")
local assets = require("assets")
local outlinerLib = require("outliner")

local weaponItem = {}

function weaponItem.new(weaponData)
    local instance = {
        position = {0, 0};
        velocity = 0;
        rotVelocity = 0;
        rotAcceleration = math.pi*8;
        realRot = 0;
        rotation = 0;
        acceleration = 2000;
        distanceToPlayer = 0;
        weaponData = weaponData or weaponManager.Pistol.new();
        src;
    }

    --Loading up quads over here
    instance.src = assets.images.weapons[string.lower(instance.weaponData.name) .. "Img"]
    instance.quad = love.graphics.newQuad(0, 0, instance.src:getWidth(), instance.src:getHeight(), instance.src:getDimensions())

    --Set up outliner
    instance.test = outlinerLib(true)
    instance.test:outline(1, 1, 1)

    function instance:update(delta)
        --Move
        self.position[1] = self.position[1] + self.velocity*math.cos(self.realRot)*delta
        self.position[2] = self.position[2] + self.velocity*math.sin(self.realRot)*delta
        --Slow down
        self.velocity = self.velocity - self.acceleration*delta
        if self.velocity < 0 then self.velocity = 0 end
        --Turn & velocity decrease
        self.rotation = self.rotation - self.rotVelocity*delta
        self.rotVelocity = self.rotVelocity - self.rotAcceleration*delta
        if self.rotVelocity < 0 then self.rotVelocity = 0 end

        --Distance calculation
        self.distanceToPlayer = math.sqrt(
            (self.position[1]-Player.position[1])*(self.position[1]-Player.position[1])
            + (self.position[2]-Player.position[2])*(self.position[2]-Player.position[2])
        )
    end

    function instance:draw()
        local src = instance.src
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        --Draw image
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            2*Camera.zoom, 2*Camera.zoom, width/2, height/2
        )
        
        --Draw outline
        if self.distanceToPlayer > 100 then return end
        love.graphics.push()
            love.graphics.translate(pos[1], pos[2])
            love.graphics.scale(2, 2)
            love.graphics.rotate(self.rotation)
            self.test:draw(0.5, src, instance.quad, -width/2, -height/2)
        love.graphics.pop()
    end

    return instance
end

return weaponItem