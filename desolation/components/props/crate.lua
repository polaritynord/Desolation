local coreFuncs = require("coreFuncs")
local physicsProp = require("desolation.components.props.physics_prop")
local particleFuncs = require("desolation.particle_funcs")

local crateScript = table.new(physicsProp)

function crateScript:bulletHitEvent(crate)
    local source = Assets.mapSounds["hit_crate" .. math.random(1, 2)]
    source:setVolume(Settings.vol_master * Settings.vol_world)
    source:stop() ; source:play()
end

function crateScript:destroyEvent(crate)
    local comp = CurrentScene.bullets.particleComponent
    if Settings.destruction_particles then
        particleFuncs.createCrateWoodParticles(comp, crate.position)
    end
end

function crateScript:load()
    local crate = self.parent
    self:setup()
    --load image if nonexistant
    if Assets.mapImages["prop_crate"] == nil then
        Assets.mapImages["prop_crate"] = love.graphics.newImage("desolation/assets/images/props/crate.png")
    end
    --load hit sounds
    for i = 1, 2 do
        if Assets.mapSounds["hit_crate" .. i] == nil then
            Assets.mapSounds["hit_crate" .. i] = love.audio.newSource("desolation/assets/sounds/hit_crate" .. i .. ".wav", "static")
        end
    end
    crate.imageComponent = ENGINE_COMPONENTS.imageComponent.new(crate, Assets.mapImages["prop_crate"])
    crate.scale = {2.5+coreFuncs.boolToNum(crate.name == "crate_big"), 2.5+coreFuncs.boolToNum(crate.name == "crate_big")}
end

function crateScript:update(delta)
    if GamePaused then return end
    self:physicsUpdate(delta)
end

return crateScript