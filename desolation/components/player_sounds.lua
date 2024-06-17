local coreFuncs = require "coreFuncs"

local playerSounds = ENGINE_COMPONENTS.scriptComponent.new()

function playerSounds:playStopSound(sound)
    if sound == nil then return end
    sound:setVolume(Settings.vol_master * Settings.vol_world)
    love.audio.stop(sound)
    love.audio.play(sound)
end

function playerSounds:stopSound(sound)
    if sound == nil then return end
    love.audio.stop(sound)
end

function playerSounds:playSound(sound)
    if sound == nil then return end
    sound:setVolume(Settings.vol_master * Settings.vol_world)
    love.audio.play(sound)
end

function playerSounds:load()
    self.stepTimer = 0
    self.sounds = {
        step = {grass = {}};
        shoot = {};
        reload = {};
        hurt = {};
        progress = {};
    }
    --Load footsteps
    for i = 1, 10 do
        local src = love.audio.newSource("desolation/assets/sounds/footstep/grass" .. i .. ".wav", "static")
        Assets.sounds["step_grass" .. i] = src
        --self.sounds.step[#self.sounds.step+1] = src
    end
    --Weapon sfx
    Assets.sounds["reload_pistol"] = love.audio.newSource("desolation/assets/sounds/weapons/reload_pistol.wav", "static")
    Assets.sounds["shoot_pistol"] = love.audio.newSource("desolation/assets/sounds/weapons/shoot_pistol.wav", "static")
    Assets.sounds["reload_revolver"] = love.audio.newSource("desolation/assets/sounds/weapons/reload_revolver.wav", "static")
    Assets.sounds["shoot_revolver"] = love.audio.newSource("desolation/assets/sounds/weapons/shoot_revolver.wav", "static")
    Assets.sounds["reload_assaultrifle"] = love.audio.newSource("desolation/assets/sounds/weapons/reload_assault_rifle.wav", "static")
    Assets.sounds["shoot_assaultrifle"] = love.audio.newSource("desolation/assets/sounds/weapons/shoot_assault_rifle.wav", "static")
    Assets.sounds["reload_shotgun"] = love.audio.newSource("desolation/assets/sounds/weapons/reload_shotgun.wav", "static")
    Assets.sounds["shoot_shotgun"] = love.audio.newSource("desolation/assets/sounds/weapons/shoot_shotgun.wav", "static")
    Assets.sounds["progress_shotgun"] = love.audio.newSource("desolation/assets/sounds/weapons/progress_shotgun.wav", "static")
    Assets.sounds["empty_mag"] = love.audio.newSource("desolation/assets/sounds/weapons/empty_mag.wav", "static")
    --Item sfx
    Assets.sounds["acquire"] = love.audio.newSource("desolation/assets/sounds/acquire.wav", "static")
    Assets.sounds["drop"] = love.audio.newSource("desolation/assets/sounds/drop.wav", "static")
    --Hurt sfx
    for i = 1, 3 do
        Assets.sounds["hurt" .. i] = love.audio.newSource("desolation/assets/sounds/hurt" .. i .. ".wav", "static")
    end
end

function playerSounds:update(delta)
    --footstep sounds
    local player = self.parent.parent
    if player.moving then
        self.stepTimer = self.stepTimer + delta
        if self.stepTimer > 0.4 - coreFuncs.boolToNum(player.sprinting)*0.15 then
            --love.audio.stop(self.sounds.step)
            love.audio.play(Assets.sounds["step_grass" .. math.random(1, 10)])
            self.stepTimer = 0
        end
    else
        self.stepTimer = 0
    end
end

return playerSounds