local physicsProp = require("desolation.components.props.physics_prop")
local coreFuncs = require("coreFuncs")

local crateScript = table.new(physicsProp)

function crateScript:bulletHitEvent(crate)
    local source = Assets.mapSounds["hit_barrel" .. math.random(1, 3)]
    SoundManager:restartSound(source, Settings.vol_world, crate.position, true)
end

function crateScript:load()
    local barrel = self.parent
    self:setup()
    --load hit sounds
    for i = 1, 3 do
        if Assets.mapSounds["hit_barrel" .. i] == nil then
            Assets.mapSounds["hit_barrel" .. i] = love.audio.newSource("desolation/assets/sounds/hit_barrel" .. i .. ".wav", "static")
        end
    end
    barrel.imageComponent = ENGINE_COMPONENTS.imageComponent.new(barrel, Assets.mapImages["prop_barrel"])
    barrel.scale = {2.5, 2.5}
end

function crateScript:update(delta)
    if GamePaused then return end
    self:physicsUpdate(delta)
end

return crateScript