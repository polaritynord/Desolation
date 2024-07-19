local coreFuncs = require("coreFuncs")
local physicsProp = require("desolation.components.props.physics_prop")
local particleFuncs = require("desolation.particle_funcs")

local crateScript = table.new(physicsProp)

function crateScript:bulletHitEvent(crate)
    local source = Assets.mapSounds["hit_crate" .. math.random(1, 2)]
    SoundManager:restartSound(source, Settings.vol_world, crate.position, true)
end

function crateScript:destroyEvent(crate)
    local comp = CurrentScene.bullets.particleComponent
    if Settings.destruction_particles then
        particleFuncs.createCrateWoodParticles(comp, crate.position)
    end
    --(Infinite mode)
    if not CurrentScene.regenerateProps then return end
    local crateData = CurrentScene.props["openarea_manager"].script:setRandomCrateData()
    CurrentScene.mapCreator.script:spawnProp(crateData)
    CurrentScene.cratesBroken = CurrentScene.cratesBroken + 1
end

function crateScript:load()
    local crate = self.parent
    self:setup()
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