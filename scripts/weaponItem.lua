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
        gettingPickedUp = false;
        alpha = 1;
    }

    --Loading up quads over here
    instance.src = assets.images.weapons[string.lower(instance.weaponData.name) .. "Img"]
    instance.quad = love.graphics.newQuad(0, 0, instance.src:getWidth(), instance.src:getHeight(), instance.src:getDimensions())

    --Set up outliner
    instance.test = outlinerLib(true)
    instance.test:outline(1, 1, 1)

    function instance:movement(delta)
        if self.gettingPickedUp then
            self.position[1] = self.position[1] + (Player.position[1]-self.position[1])*10*delta
            self.position[2] = self.position[2] + (Player.position[2]-self.position[2])*10*delta
            self.alpha = self.distanceToPlayer/100
        else
            --Move
            self.position[1] = self.position[1] + self.velocity*math.cos(self.realRot)*delta
            self.position[2] = self.position[2] + self.velocity*math.sin(self.realRot)*delta
            --Slow down
            self.velocity = self.velocity - self.acceleration*delta
            if self.velocity < 0 then self.velocity = 0 end
            --Turn & velocity decrease
            self.rotation = self.rotation - self.rotVelocity*delta
            self.rotVelocity = self.rotVelocity + (-self.rotVelocity)*math.pi*2*delta
            --self.rotVelocity = self.rotVelocity - self.rotAcceleration*delta
            --if self.rotVelocity < 0 then self.rotVelocity = 0 end
        end
    end

    function instance:update(delta, i)
        --Remove self if getting picked up is complete
        if self.distanceToPlayer < 10 and self.gettingPickedUp then
            table.remove(MapManager.weaponItems, i)
        end

        self:movement(delta)

        --Distance calculation
        self.distanceToPlayer = math.sqrt(
            (self.position[1]-Player.position[1])*(self.position[1]-Player.position[1])
            + (self.position[2]-Player.position[2])*(self.position[2]-Player.position[2])
        )

        if self.distanceToPlayer > 100 then return end
        --Picking up
        if love.keyboard.isDown("e") and not self.gettingPickedUp then
            --check if player has an empty slot (TODO: optimize)
            local weaponInv = Player.inventory.weapons
            local emptySlot = 0
            if weaponInv[Player.inventory.slot] == nil then
                emptySlot = Player.inventory.slot
            else
                for i = 1, 3 do
                    if weaponInv[i] == nil then emptySlot = i; break end
                end
            end
            if emptySlot < 1 then return end
            self.gettingPickedUp = true
            --Add self to player inventory
            weaponInv[emptySlot] = self.weaponData.new()
        end
    end

    function instance:draw()
        love.graphics.setColor(1,1,1,self.alpha)
        local src = instance.src
        local width = src:getWidth() ;  local height = src:getHeight()
        local pos = coreFuncs.getRelativePosition(self.position, Camera)
        --Draw image
        love.graphics.draw(
            src, pos[1], pos[2], self.rotation,
            2*Camera.zoom, 2*Camera.zoom, width/2, height/2
        )
        love.graphics.setColor(1,1,1,1)

        --Draw outline
        if self.distanceToPlayer > 100 or self.gettingPickedUp then return end
        
        love.graphics.push()
            love.graphics.translate(pos[1], pos[2])
            love.graphics.scale(2, 2)
            love.graphics.rotate(self.rotation)
            self.test:draw(0.5, src, instance.quad, -width/2, -height/2)
        love.graphics.pop()

        --Draw "e to pick up" thing
        --Base
        love.graphics.setColor(coreFuncs.rgb(220))
        love.graphics.rectangle("fill", pos[1]-15, pos[2]-50, 30, 30)
        --Key (TODO: Change this after adding bindings)
        love.graphics.setColor(coreFuncs.rgb(50))
        SetFont("assets/fonts/disposable-droid-bold.ttf", 32)
        love.graphics.printf("E", pos[1]-8, pos[2]-50, 1000, "left")
        
        love.graphics.setColor(1,1,1,1)
    end

    return instance
end

return weaponItem