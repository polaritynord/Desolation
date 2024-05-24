local coreFuncs = require "coreFuncs"
local playerSounds = {}

function playerSounds:load()
    self.stepTimer = 0
    self.sounds = {
        step = {grass = {}}
    }
    --Load footsteps
    for i = 1, 10 do
        self.sounds.step.grass[#self.sounds.step.grass+1] = love.audio.newSource("fdh/assets/sounds/footstep_grass" .. i .. ".wav", "static")
    end
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