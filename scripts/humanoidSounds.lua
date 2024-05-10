local humanoidSounds = {}

function humanoidSounds.new()
    local instance = {
        sources = {
            step = {grass = {}};
            shoot = {};
            reload = {};
        };
        stepTimer = 0;
    }

    function instance:load()
        --Load footsteps
        for i = 1, 10 do
            self.sources.step.grass[#self.sources.step.grass+1] = love.audio.newSource("fdh/assets/sounds/footstep_grass" .. i .. ".wav", "static")
        end
        --Weapon sfx
        self.sources.reload.Pistol = love.audio.newSource("fdh/assets/sounds/rld_pistol.wav", "static")
        self.sources.shoot.Pistol = love.audio.newSource("fdh/assets/sounds/shoot_pistol.wav", "static")
        self.sources.shoot.empty = love.audio.newSource("fdh/assets/sounds/empty_mag.wav", "static")
    end

    function instance:shootWeapon(weaponName)
        love.audio.stop(self.sources.shoot[weaponName])
        love.audio.play(self.sources.shoot[weaponName])
    end

    function instance:reloadWeapon(weaponName)
        love.audio.stop(self.sources.reload[weaponName])
        love.audio.play(self.sources.reload[weaponName])
    end

    function instance:emptyMag()
        love.audio.stop(self.sources.shoot.empty)
        love.audio.play(self.sources.shoot.empty)
    end

    function instance:update(delta)
        --Player step sounds
        if Player.moving then
            self.stepTimer = self.stepTimer + delta
            if self.stepTimer > 0.4 or (Player.sprinting and self.stepTimer > 0.25) then
                love.audio.stop(self.sources.step.grass)
                love.audio.play(self.sources.step.grass[math.random(1, #self.sources.step.grass)])
                self.stepTimer = 0
            end
        else
            self.stepTimer = 0
        end
    end

    return instance
end

return humanoidSounds