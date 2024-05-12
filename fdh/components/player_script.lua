local coreFuncs = require("coreFuncs")

local playerScript = {}

function playerScript:movement(delta, player)
    local transform = player.transformComponent

    local speed = GetGlobal("p_speed")
    self.velocity = {x=0, y=0}
    --Get key input
    if love.keyboard.isDown("a") then
        self.velocity.x = self.velocity.x - 1
    end
    if love.keyboard.isDown("d") then
        self.velocity.x = self.velocity.x + 1
    end
    if love.keyboard.isDown("w") then
        self.velocity.y = self.velocity.y - 1
    end
    if love.keyboard.isDown("s") then
        self.velocity.y = self.velocity.y + 1
    end
    --Sprinting
    local sprintMultiplier = 1.6
    self.sprinting = InputManager:isPressed("sprint")
    if self.sprinting then
        self.velocity.x = self.velocity.x * sprintMultiplier
        self.velocity.y = self.velocity.y * sprintMultiplier
    end
    --Normalize velocity
    if math.abs(self.velocity.x) == math.abs(self.velocity.y) then
        self.velocity.x = self.velocity.x * math.sin(math.pi/4)
        self.velocity.y = self.velocity.y * math.sin(math.pi/4)
    end
    self.moving = math.abs(self.velocity.x) > 0 or math.abs(self.velocity.y) > 0
    --Move by velocity
    transform.x = transform.x + (self.velocity.x*speed*delta)
    transform.y = transform.y + (self.velocity.y*speed*delta)
end

function playerScript:pointTowardsMouse(player)
    local mouseX, mouseY = love.mouse.getPosition()
    local pos = coreFuncs.getRelativePosition(player.transformComponent, CurrentScene.camera)
    local dx = mouseX-pos[1] ; local dy = mouseY-pos[2]
    player.transformComponent.rotation = math.atan2(dy, dx)
end

--Engine funcs
function playerScript:load()
    local player = self.parent
    local transform = player.transformComponent
    player.imageComponent.source = Assets.images.player.body
    transform.scale = {x=4, y=4}
    --Variables
    player.velocity = {x=0, y=0}
end

function playerScript:update(delta)
    local player = self.parent
    self:movement(delta, player)
    self:pointTowardsMouse(player)
end

return playerScript