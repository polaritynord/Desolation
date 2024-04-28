local assets = require("assets")
local coreFuncs = require("coreFuncs")
local humanoid = require("scripts.humanoid")
local weaponManager = require("scripts.weaponManager")
local weaponItem = require("scripts.weaponItem")
local mapManager = require("scripts.mapManager")

local player = {}

function player.new()
    local instance = humanoid.new()

    --Player variables
    instance.inventory.previousSlot = nil
    instance.keyPressData = {
        ["q"] = false;
    }

    --Changes camera zoom dynamically depending on current sprinting state.
    function instance:changeCameraZoom(delta)
        local sprintScale = 1.035
        local smoothness = 10
        local d
        if self.sprinting then
            d = (sprintScale-Camera.zoom) * smoothness * delta
        else
            d = (1-Camera.zoom) * smoothness * delta
        end
        Camera.zoom = Camera.zoom + d
    end

    function instance:movement(delta)
        local speed = GetGlobal("p_speed")
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
        --Sprinting
        local sprintMultiplier = 1.6
        self.sprinting = love.keyboard.isDown("lshift")
        if self.sprinting then
            self.velocity[1] = self.velocity[1] * sprintMultiplier
            self.velocity[2] = self.velocity[2] * sprintMultiplier
        end
        --Normalize velocity
        if math.abs(self.velocity[1]) == math.abs(self.velocity[2]) then
            self.velocity[1] = self.velocity[1] * math.sin(math.pi/4)
            self.velocity[2] = self.velocity[2] * math.sin(math.pi/4)
        end
        self.moving = math.abs(self.velocity[1]) > 0 or math.abs(self.velocity[2]) > 0
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

    function instance:slotSwitching()
        local oldSlot = self.inventory.slot
        --Switch slot with number keys
        for i = 1, 3 do
            if love.keyboard.isDown(tostring(i)) and i ~= self.inventory.slot then
                self.inventory.previousSlot = self.inventory.slot
                self.inventory.slot = i
            end
        end
        --Quick slot switching
        if love.keyboard.isDown("q") and not self.keyPressData["q"] and self.inventory.previousSlot then
            local temp = self.inventory.previousSlot
            self.inventory.previousSlot = self.inventory.slot
            self.inventory.slot = temp
        end
        self.keyPressData["q"] = love.keyboard.isDown("q")
        --Update hand offset
        if oldSlot ~= self.inventory.slot and self.inventory.weapons[oldSlot] ~= self.inventory.weapons[self.inventory.slot] then
            self.handOffset = -15
        end
        --Cancel reload if slot switching is done
        if oldSlot ~= self.inventory.slot then self.reloading = false end
    end

    function instance:weaponDropping()
        local weapon = self.inventory.weapons[self.inventory.slot]
        if not love.keyboard.isDown("v") or not weapon then return end
        --Create new weaponItem instance & pass the values to it
        local itemInstance = weaponItem.new(weapon.new())
        itemInstance.position = {self.position[1], self.position[2]}
        itemInstance.velocity = 550
        itemInstance.rotVelocity = math.uniform(-1, 1)*math.pi*12 --TODO this could've been better
        itemInstance.realRot = self.rotation

        mapManager:newWeaponItem(itemInstance)
        --Get rid of the held weapon
        self.inventory.weapons[self.inventory.slot] = nil
    end

    function instance:shootingWeapon(delta)
        self.shootTimer = self.shootTimer + delta
        local weapon = self.inventory.weapons[self.inventory.slot]
        if not weapon or self.reloading then return end
        if love.mouse.isDown(1) and self.shootTimer > weapon.shootTime then
            --Check if there is ammo available in magazine
            if weapon.magAmmo > 0 then
                --Fire weapon
                for i = 1, weapon.bulletPerShot do
                    weapon.magAmmo = weapon.magAmmo - 1
                end
                self.handOffset = -weapon.handRecoilIntensity
                self.sounds:shootWeapon(weapon.name)
            else
                --Empty magazine
                self.sounds:emptyMag()
            end
            self.shootTimer = 0
        end
    end

    function instance:reloadingWeapon(delta)
        local weapon = self.inventory.weapons[self.inventory.slot]
        --Returning if no weapon is being held
        if not weapon then return end
        --Returning if: no ammunition is left, the mag is full
        if weapon.magAmmo == weapon.magSize or self.inventory.ammunition[weapon.ammoType] < 1 then return end
        if Player.reloading then
            self.reloadTimer = self.reloadTimer + delta
            if self.reloadTimer > weapon.reloadTime then
                self.reloadTimer = 0
                self.reloading = false
                --Actual reloading stuff
                local ammoNeeded = weapon.magSize - weapon.magAmmo
                if ammoNeeded > self.inventory.ammunition[weapon.ammoType] then
                    --If the place to fill is greater than the amount of ammunition
                    weapon.magAmmo = weapon.magAmmo + self.inventory.ammunition[weapon.ammoType]
                    self.inventory.ammunition[weapon.ammoType] = 0
                else
                    --..Or if there's more
                    weapon.magAmmo = weapon.magAmmo + ammoNeeded
                    self.inventory.ammunition[weapon.ammoType] = self.inventory.ammunition[weapon.ammoType] - ammoNeeded
                end
            end
        else
            if love.keyboard.isDown("r") then
                self.sounds:reloadWeapon(weapon.name)
                self.reloading = true
            end
        end
    end

    --Core functions
    function instance:load()
        --Create item slots in inventory
        for i = 1, 40 do
            self.inventory.items[#self.inventory.items+1] = {}
        end
        --Some inventory testin stuff
        self.inventory.weapons[1] = weaponManager.Pistol.new()
        self.inventory.weapons[1].magAmmo = 6
        self.inventory.ammunition["light"] = 78
        --Sound channel
        self.sounds:load()
    end

    function instance:update(delta)
        if GamePaused then return end
        self:movement(delta)
        self:pointTowardsMouse()
        self:slotSwitching()
        self:weaponDropping()
        self:shootingWeapon(delta)
        self:reloadingWeapon(delta)
        if GetGlobal("freecam") < 1 then
            Camera:followTarget(self, 8, delta)
            self:changeCameraZoom(delta)
        else
            Camera:freecamControls()
        end
        self:doWalkingAnim()
        self.sounds:update(delta)
        --Update hand offset
        self.handOffset = self.handOffset + (-self.handOffset) * 20 * delta
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
            4*Camera.zoom + self.animationSizeDiff, 4*Camera.zoom + self.animationSizeDiff, width/2, height/2
        )
    end

    return instance
end

return player