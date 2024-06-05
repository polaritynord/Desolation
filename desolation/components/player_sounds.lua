local coreFuncs = require "coreFuncs"

local playerSounds = ENGINE_COMPONENTS.scriptComponent.new()

function playerSounds:playStopSound(sound)
    if sound == nil then return end
    love.audio.stop(sound)
    love.audio.play(sound)
end

function playerSounds:stopSound(sound)
    if sound == nil then return end
    love.audio.stop(sound)
end

function playerSounds:playSound(sound)
    if sound == nil then return end
    love.audio.play(sound)
end

function playerSounds:load()
    self.stepTimer = 0
    self.sounds = {
        step = {grass = {}};
        shoot = {};
        reload = {};
    }
    --Load footsteps
    for i = 1, 10 do
        self.sounds.step.grass[#self.sounds.step.grass+1] = love.audio.newSource("desolation/assets/sounds/footstep/grass" .. i .. ".wav", "static")
    end
    --Weapon sfx
    self.sounds.reload.Pistol = love.audio.newSource("desolation/assets/sounds/weapons/rld_pistol.wav", "static")
    self.sounds.shoot.Pistol = love.audio.newSource("desolation/assets/sounds/weapons/shoot_pistol.wav", "static")
    self.sounds.shoot.empty = love.audio.newSource("desolation/assets/sounds/weapons/empty_mag.wav", "static")
    --Item sfx
    self.sounds.acquire = love.audio.newSource("desolation/assets/sounds/acquire.wav", "static")
    self.sounds.drop = love.audio.newSource("desolation/assets/sounds/drop.wav", "static")
end

function playerSounds:update(delta)
    --footstep sounds
    local player = self.parent.parent
    if player.moving then
        self.stepTimer = self.stepTimer + delta
        if self.stepTimer > 0.4 - coreFuncs.boolToNum(player.sprinting)*0.15 then
            love.audio.stop(self.sounds.step.grass)
            love.audio.play(self.sounds.step.grass[math.random(1, #self.sounds.step.grass)])
            self.stepTimer = 0
        end
    else
        self.stepTimer = 0
    end
end

return playerSounds