local coreFuncs = require "coreFuncs"
local playerSounds = {}

function playerSounds:shootWeapon(weaponName)
    love.audio.stop(self.sounds.shoot[weaponName])
    love.audio.play(self.sounds.shoot[weaponName])
end

function playerSounds:reloadWeapon(weaponName)
    love.audio.stop(self.sounds.reload[weaponName])
    love.audio.play(self.sounds.reload[weaponName])
end

function playerSounds:emptyMag()
    love.audio.stop(self.sounds.shoot.empty)
    love.audio.play(self.sounds.shoot.empty)
end

function playerSounds:acquire()
    love.audio.stop(self.sounds.acquire)
    love.audio.play(self.sounds.acquire)
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
        self.sounds.step.grass[#self.sounds.step.grass+1] = love.audio.newSource("fdh/assets/sounds/footstep_grass" .. i .. ".wav", "static")
    end
    --Weapon sfx
    self.sounds.reload.Pistol = love.audio.newSource("fdh/assets/sounds/rld_pistol.wav", "static")
    self.sounds.shoot.Pistol = love.audio.newSource("fdh/assets/sounds/shoot_pistol.wav", "static")
    self.sounds.shoot.empty = love.audio.newSource("fdh/assets/sounds/empty_mag.wav", "static")
    --Item sfx
    self.sounds.acquire = love.audio.newSource("fdh/assets/sounds/acquire.wav", "static")
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