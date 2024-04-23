local playerSounds = {
    sources = {
        step = {grass = {}};
    };
    stepTimer = 0;
}

function playerSounds:load()
    --Load footsteps
    for i = 1, 3 do
        self.sources.step.grass[#self.sources.step.grass+1] = love.audio.newSource("assets/sounds/footstep_grass" .. i .. ".wav", "static")
    end
end

function playerSounds:update(delta)
    --Player step sounds
    if Player.moving then
        self.stepTimer = self.stepTimer + delta
        if self.stepTimer > 0.4 then
            love.audio.stop(self.sources.step.grass)
            love.audio.play(self.sources.step.grass[math.random(1, #self.sources.step.grass)])
            self.stepTimer = 0
        end
    else
        self.stepTimer = 0
    end
end

return playerSounds