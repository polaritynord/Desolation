local coreFuncs = require("coreFuncs")
local particleFuncs = require("desolation.particle_funcs")
local powerOrbScript = ENGINE_COMPONENTS.scriptComponent.new()

--Custom draw function for power orb with the background circle & icon
local function drawOrb(self)
    local camera = CurrentScene.camera
    local pos = coreFuncs.getRelativePosition(self.parent.position, camera)
    --Draw circle
    love.graphics.setColor(0.15, 0.2, 0.9, 0.7*self.parent.imageComponent.color[4])
    love.graphics.draw(
        Assets.mapImages["orb_circle"], pos[1], pos[2], self.parent.rotation,
        camera.zoom*self.parent.scale[1]*1.6, camera.zoom*self.parent.scale[2]*1.6, 8, 8
    )
    love.graphics.setColor(unpack(self.parent.imageComponent.color))
    --Draw orb icon
    love.graphics.draw(
        self.source, self.quad, pos[1], pos[2], self.parent.rotation,
        camera.zoom*self.parent.scale[1], camera.zoom*self.parent.scale[2], 10, 10
    )
    love.graphics.setColor(1, 1, 1, 1)
end

local function doSinWaveAnimation(orb, delta)
    orb.scale[1] = 2.5 + math.sin(orb.animTimer*3)/5
    orb.scale[2] = orb.scale[1]
    orb.animTimer = orb.animTimer + delta
end

local function playerAcquireCheck(orb, player)
    --Measure distance to player
    local distance = coreFuncs.pointDistance(orb.position, player.position)
    if distance >= 75 then return end
    orb.acquired = true
    SoundManager:restartSound(Assets.mapSounds["acquire_power_orb"], Settings.vol_world)
    particleFuncs.createPowerOrbAcquireParticles(orb, CurrentScene.bullets.particleComponent)
    CurrentScene.currentPowerup = orb.type
    CurrentScene.powerupTimer = 5
    --TODO custom timers for powerups
    --TODO Maybe make the powerups not start the moment you gain them,
    --but when you press "e"? Like mario kart, I guess?
    if orb.type == "speed" then
        player.stamina = 100
    end
end

--Event functions
function powerOrbScript:load()
    local orb = self.parent
    --Public properties
    orb.type = orb.type or "speed"
    orb.acquired = false
    orb.scale = {2.5, 2.5}
    orb.animTimer = 0
    orb.particleTimer = 0
    --Setup components and set draw function
    orb.imageComponent = ENGINE_COMPONENTS.imageComponent.new(orb, Assets.mapImages["power_orbs"])
    orb.imageComponent.draw = drawOrb
    orb.imageComponent.quad = love.graphics.newQuad(0, 0, 20, 20, 20, 20)
    --Add light
    orb.light = CurrentScene:addLight(orb.position[1], orb.position[2], 500, 1, 1, 1, 1)
end

function powerOrbScript:update(delta)
    if GamePaused then return end
    local orb = self.parent
    local player = CurrentScene.player
    if orb.acquired then
        --Fade out
        orb.scale[1] = orb.scale[1] + 9*delta
        orb.scale[2] = orb.scale[1]
        orb.imageComponent.color[4] = orb.imageComponent.color[4] - 8*delta
        if orb.imageComponent.color[4] < 0 then
            table.removeValue(CurrentScene.props.tree, orb)
            CurrentScene:removeLight(orb.light)
        end
    else
        doSinWaveAnimation(orb, delta)
        playerAcquireCheck(orb, player)
        if orb.particleTimer > 0.02 then
            particleFuncs.createPowerOrbIdleParticles(orb, CurrentScene.bullets.particleComponent)
            orb.particleTimer = 0
        end
        orb.particleTimer = orb.particleTimer + delta
    end
end

return powerOrbScript